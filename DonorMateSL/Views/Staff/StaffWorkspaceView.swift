//
//  StaffWorkspaceView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/27/26.
//

import SwiftUI

private enum StaffRecordPhase {
    case scanning
    case comparing
    case comparison
    case manualLookup
    case recordDetail
    case recordNotFound
    case serviceError
}

struct StaffWorkspaceView: View {
    let staff: StaffIdentity
    let onExit: () -> Void

    @Environment(\.scenePhase) private var scenePhase
    @State private var navigation = StaffNavigation()
    @State private var scan = StaffScanSession()
    @State private var scanErrorMessage: String?
    @State private var scanGeneration = UUID()
    @State private var recognitionTask: Task<Void, Never>?
    @State private var recordPhase: StaffRecordPhase = .scanning
    @State private var comparison: StaffIdentityComparison?
    @State private var selectedRecord: StaffDonorIdentityRecord?
    @State private var manualNIC = ""
    @State private var manualError: String?
    @State private var openedFromManualLookup = false
    @State private var recentChecks: [String] = []
    @State private var lookupGeneration = UUID()
    @State private var lookupTask: Task<Void, Never>?

    var body: some View {
        GeometryReader { geometry in
            if StaffLayoutPolicy.mode(forWidth: Double(geometry.size.width)) == .expanded {
                HStack(spacing: 0) {
                    StaffSidebar(
                        staff: staff,
                        active: navigation.section,
                        onDashboard: showDashboard,
                        onVerify: startVerification,
                        onExit: signOut
                    )
                    .frame(width: 250)
                    Divider()
                    staffContent(for: navigation.section, compact: false)
                }
            } else {
                TabView(selection: selectedTab) {
                    compactPage(for: .dashboard)
                        .tabItem { Label("Dashboard", systemImage: "house.fill") }
                        .tag(StaffSection.dashboard.rawValue)

                    compactPage(for: .verifyDonor)
                        .tabItem { Label("Verify Donor", systemImage: "person.text.rectangle") }
                        .tag(StaffSection.verifyDonor.rawValue)
                }
                .tint(Color("DonorRed"))
            }
        }
        .background(Color("BackgroundPrimary"))
        .alert("Scan could not be completed", isPresented: Binding(
            get: { scanErrorMessage != nil },
            set: { if !$0 { scanErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { scanErrorMessage = nil }
        } message: {
            Text(scanErrorMessage ?? "Please try again.")
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                invalidatePendingScan()
                invalidatePendingLookup()
                scan.reset()
                clearRecordReview()
                navigation.showDashboard()
            }
        }
    }

    private var selectedTab: Binding<String> {
        Binding(
            get: { navigation.section.rawValue },
            set: { newValue in
                if newValue == StaffSection.verifyDonor.rawValue {
                    startVerification()
                } else {
                    showDashboard()
                }
            }
        )
    }

    private func compactPage(for section: StaffSection) -> some View {
        VStack(spacing: 0) {
            if section == .dashboard {
                HStack {
                    Text("Staff Dashboard")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))
                    Spacer()
                    Button("Sign Out", action: signOut)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color("DonorRed"))
                        .accessibilityHint("Ends this staff session")
                }
                .frame(height: 44)
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(Color("BackgroundPrimary"))
            } else {
                ScreenNavigationHeader(
                    title: "Verify Donor",
                    onBack: handleBack
                )
            }

            staffContent(for: section, compact: true)
        }
    }

    private func staffContent(for section: StaffSection, compact: Bool) -> some View {
        ScreenScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if section == .dashboard {
                    StaffDashboardView(
                        staff: staff,
                        recentChecks: recentChecks,
                        onStartVerification: startVerification,
                        onManualLookup: openManualLookup
                    )
                } else {
                    verificationContent
                }
            }
            .padding(.horizontal, compact ? 18 : 28)
            .padding(.top, compact ? 18 : 28)
            .padding(.bottom, compact ? 170 : 28)
            .frame(maxWidth: 1020, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .background(Color("BackgroundPrimary"))
    }

    @ViewBuilder
    private var verificationContent: some View {
        switch recordPhase {
        case .scanning:
            scanContent

        case .comparing:
            VStack(alignment: .leading, spacing: 20) {
                StaffPageHeading(
                    eyebrow: "Record comparison",
                    title: "Checking donor record",
                    subtitle: "Comparing captured details with the available donor record."
                )
                StaffPanel {
                    ProgressView("Checking record…")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                }
            }

        case .comparison:
            if let comparison {
                StaffIdentityComparisonView(
                    comparison: comparison,
                    onContinue: openComparedRecord,
                    onScanAgain: resetForAnotherScan,
                    onManualLookup: openManualLookup
                )
            }

        case .manualLookup:
            StaffManualLookupView(
                nicNumber: $manualNIC,
                error: manualError,
                onSearch: lookupManualNIC,
                onBack: showDashboard
            )

        case .recordDetail:
            if let selectedRecord {
                StaffDonorRecordDetailView(
                    record: selectedRecord,
                    reachedByManualLookup: openedFromManualLookup,
                    onFinish: showDashboard,
                    onScanAnother: resetForAnotherScan
                )
            }

        case .recordNotFound:
            StaffRecordNotFoundView(
                onScanAgain: resetForAnotherScan,
                onManualLookup: openManualLookup
            )

        case .serviceError:
            StaffRecordServiceErrorView(
                onRetry: { if openedFromManualLookup { lookupManualNIC() } else { compareWithRecord() } },
                onBack: showDashboard
            )
        }
    }

    @ViewBuilder
    private var scanContent: some View {
        switch scan.stage {
        case .instructions:
            StaffScanInstructionsView(
                onOpenScanner: { scan.showCapture() },
                onBack: showDashboard
            )

        case .capture:
            StaffScanCaptureView(
                onCaptured: processImages,
                onBack: { scan.reset() },
                onError: { scanErrorMessage = $0 }
            )

        case .processing:
            StaffScanProcessingView()

        case .review:
            if let result = scan.result {
                StaffScanReviewView(
                    result: result,
                    onCompareRecord: compareWithRecord,
                    onScanAgain: resetForAnotherScan,
                    onFinish: showDashboard
                )
            }
        }
    }

    private func processImages(_ images: [Data], source: StaffScanSource) {
        do {
            try StaffTextRecognitionService.validate(images)
        } catch {
            scanErrorMessage = (error as? LocalizedError)?.errorDescription
                ?? "Please choose another image and try again."
            return
        }

        guard scan.beginProcessing() else { return }
        recognitionTask?.cancel()
        let generation = UUID()
        scanGeneration = generation

        recognitionTask = Task {
            defer {
                if scanGeneration == generation { recognitionTask = nil }
            }
            do {
                let lines = try await StaffTextRecognitionService.recognize(images: images)
                guard !Task.isCancelled, scanGeneration == generation else { return }
                if !scan.complete(source: source, lines: lines) {
                    scanErrorMessage = StaffTextRecognitionError.noReadableText.localizedDescription
                }
            } catch {
                guard !Task.isCancelled, scanGeneration == generation else { return }
                scan.failProcessing()
                scanErrorMessage = (error as? LocalizedError)?.errorDescription
                    ?? "The card could not be read. Please try again."
            }
        }
    }

    private func resetForAnotherScan() {
        invalidatePendingScan()
        invalidatePendingLookup()
        clearRecordReview()
        scan.showCapture()
        navigation.showVerificationInstructions()
    }

    private func startVerification() {
        invalidatePendingScan()
        invalidatePendingLookup()
        clearRecordReview()
        scan.reset()
        navigation.showVerificationInstructions()
    }

    private func compareWithRecord() {
        guard let result = scan.result else { return }
        let fields = StaffIdentityFields(result: result)

        guard let nic = fields.nicNumber,
              NationalIdentityNumberValidator.validated(nic) != nil else {
            comparison = StaffIdentityComparison.evaluate(scanned: fields, record: nil)
            recordPhase = .comparison
            rememberCheck("Scan requires manual review")
            return
        }

        invalidatePendingLookup()
        let generation = UUID()
        lookupGeneration = generation
        openedFromManualLookup = false
        recordPhase = .comparing

        lookupTask = Task {
            defer { if lookupGeneration == generation { lookupTask = nil } }
            do {
                let record = try await DemoStaffDonorIdentityLookup().findRecord(nicNumber: nic)
                guard !Task.isCancelled, lookupGeneration == generation else { return }
                comparison = StaffIdentityComparison.evaluate(scanned: fields, record: record)
                recordPhase = .comparison
                if let outcome = comparison?.outcome {
                    rememberCheck(label(for: outcome))
                }
            } catch {
                guard !Task.isCancelled, lookupGeneration == generation else { return }
                recordPhase = .serviceError
            }
        }
    }

    private func openComparedRecord() {
        guard let comparison,
              comparison.canOpenSampleRecord,
              let record = comparison.record else { return }
        selectedRecord = record
        openedFromManualLookup = false
        recordPhase = .recordDetail
    }

    private func openManualLookup() {
        invalidatePendingScan()
        invalidatePendingLookup()
        scan.reset()
        clearRecordReview()
        recordPhase = .manualLookup
        navigation.showVerificationInstructions()
    }

    private func lookupManualNIC() {
        guard let validated = NationalIdentityNumberValidator.validated(manualNIC) else {
            manualError = "Enter a valid 12-digit or legacy NIC number."
            return
        }

        manualError = nil
        invalidatePendingLookup()
        let generation = UUID()
        lookupGeneration = generation
        openedFromManualLookup = true
        recordPhase = .comparing

        lookupTask = Task {
            defer { if lookupGeneration == generation { lookupTask = nil } }
            do {
                let record = try await DemoStaffDonorIdentityLookup().findRecord(nicNumber: validated)
                guard !Task.isCancelled, lookupGeneration == generation else { return }
                if let record {
                    selectedRecord = record
                    recordPhase = .recordDetail
                    rememberCheck("Manual record lookup")
                } else {
                    recordPhase = .recordNotFound
                    rememberCheck("Donor record not found")
                }
            } catch {
                guard !Task.isCancelled, lookupGeneration == generation else { return }
                recordPhase = .serviceError
            }
        }
    }

    private func label(for outcome: StaffComparisonOutcome) -> String {
        switch outcome {
        case .allFieldsAgree: return "Record details agree"
        case .addressNeedsReview: return "Address review needed"
        case .nameMismatch: return "Name mismatch — manual review"
        case .recordNotFound: return "Donor record not found"
        case .insufficientDetails: return "Scan requires manual review"
        }
    }

    private func rememberCheck(_ label: String) {
        recentChecks.insert(label, at: 0)
        if recentChecks.count > 5 { recentChecks.removeLast() }
    }

    private func clearRecordReview() {
        recordPhase = .scanning
        comparison = nil
        selectedRecord = nil
        manualNIC = ""
        manualError = nil
        openedFromManualLookup = false
    }

    private func invalidatePendingLookup() {
        lookupGeneration = UUID()
        lookupTask?.cancel()
        lookupTask = nil
    }

    private func showDashboard() {
        invalidatePendingScan()
        invalidatePendingLookup()
        scan.reset()
        clearRecordReview()
        navigation.showDashboard()
    }

    private func signOut() {
        invalidatePendingScan()
        invalidatePendingLookup()
        scan.reset()
        clearRecordReview()
        recentChecks.removeAll()
        onExit()
    }

    private func handleBack() {
        switch recordPhase {
        case .comparing:
            invalidatePendingLookup()
            recordPhase = openedFromManualLookup ? .manualLookup : .scanning
            return
        case .comparison:
            recordPhase = .scanning
            return
        case .recordDetail:
            if openedFromManualLookup { openManualLookup() }
            else { recordPhase = .comparison }
            return
        case .recordNotFound:
            openManualLookup()
            return
        case .manualLookup, .serviceError:
            showDashboard()
            return
        case .scanning:
            break
        }
        switch scan.stage {
        case .instructions:
            showDashboard()
        case .capture:
            scan.reset()
        case .processing, .review:
            resetForAnotherScan()
        }
    }

    private func invalidatePendingScan() {
        scanGeneration = UUID()
        recognitionTask?.cancel()
        recognitionTask = nil
        scanErrorMessage = nil
    }
}
