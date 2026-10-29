//
//  StaffWorkspaceView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/27/26.
//

import SwiftUI

struct StaffWorkspaceView: View {
    let staff: StaffIdentity
    let onExit: () -> Void

    @Environment(\.scenePhase) private var scenePhase
    @State private var navigation = StaffNavigation()
    @State private var scan = StaffScanSession()
    @State private var scanErrorMessage: String?
    @State private var scanGeneration = UUID()
    @State private var recognitionTask: Task<Void, Never>?

    var body: some View {
        GeometryReader { geometry in
            if StaffLayoutPolicy.mode(forWidth: Double(geometry.size.width)) == .expanded {
                HStack(spacing: 0) {
                    StaffSidebar(
                        staff: staff,
                        active: navigation.section,
                        onDashboard: showDashboard,
                        onVerify: { navigation.showVerificationInstructions() },
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
                scan.reset()
            }
        }
    }

    private var selectedTab: Binding<String> {
        Binding(
            get: { navigation.section.rawValue },
            set: { newValue in
                if newValue == StaffSection.verifyDonor.rawValue {
                    navigation.showVerificationInstructions()
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
                switch section {
                case .dashboard:
                    StaffDashboardView(
                        staff: staff,
                        onStartVerification: { navigation.showVerificationInstructions() }
                    )

                case .verifyDonor:
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
                                onScanAgain: resetForAnotherScan,
                                onFinish: showDashboard
                            )
                        }
                    }
                }
            }
            .padding(compact ? 18 : 28)
            .frame(maxWidth: 1020, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .background(Color("BackgroundPrimary"))
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
        scan.showCapture()
    }

    private func showDashboard() {
        invalidatePendingScan()
        scan.reset()
        navigation.showDashboard()
    }

    private func signOut() {
        invalidatePendingScan()
        scan.reset()
        onExit()
    }

    private func handleBack() {
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
