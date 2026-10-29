//
//  StaffScreens.swift
//  DonorMateSL
//
//  Created by user300742 on 10/27/26.
//

import SwiftUI

struct StaffDashboardView: View {
    let staff: StaffIdentity
    let recentChecks: [String]
    let onStartVerification: () -> Void
    let onManualLookup: () -> Void

    var body: some View {
        StaffPageHeading(
            eyebrow: staff.locationName,
            title: "Staff Dashboard",
            subtitle: "Find donor records and review identity details."
        )

        StaffPanel {
            VStack(alignment: .leading, spacing: 14) {
                Label("Scan donor NIC", systemImage: "person.text.rectangle")
                    .font(.title2.bold())
                Text("Scan a donor's identity card to begin a record check.")
                    .font(.subheadline)
                    .foregroundStyle(Color("TextSecondary"))
                StaffActionButton(title: "Start NIC Scan", action: onStartVerification)
                StaffActionButton(title: "Manual NIC Lookup", primary: false, action: onManualLookup)
            }
        }

        StaffPanel {
            VStack(alignment: .leading, spacing: 10) {
                Text("Recent record checks").font(.headline)
                if recentChecks.isEmpty {
                    Text("No record checks completed in this session yet.")
                        .font(.subheadline)
                        .foregroundStyle(Color("TextSecondary"))
                } else {
                    ForEach(Array(recentChecks.enumerated()), id: \.offset) { entry in
                        if entry.offset != 0 { Divider() }
                        Label(entry.element, systemImage: "doc.text.magnifyingglass")
                            .font(.subheadline)
                            .foregroundStyle(Color("TextPrimary"))
                    }
                }
            }
        }

        StaffNotice(
            message: "Review captured identity details carefully. A record comparison does not confirm medical donation eligibility."
        )
    }
}

struct StaffScanInstructionsView: View {
    let onOpenScanner: () -> Void
    let onBack: () -> Void

    var body: some View {
        StaffPageHeading(
            eyebrow: "Identity verification",
            title: "Scan donor NIC",
            subtitle: "Follow these steps to prepare the donor's identity card."
        )

        StaffPanel {
            VStack(alignment: .leading, spacing: 16) {
                instruction("1", title: "Position the card", detail: "Keep the NIC flat, in focus and entirely visible.")
                Divider()
                instruction("2", title: "Check the details", detail: "Review the identity number, name and address shown on the card.")
                Divider()
                instruction("3", title: "Confirm the record", detail: "Compare the details with the donor record before continuing.")
            }
        }

        StaffActionButton(title: "Continue to Scan", action: onOpenScanner)
        StaffActionButton(title: "Back to Dashboard", primary: false, action: onBack)

        StaffNotice(
            message: "Please check the donor's identity details carefully before confirming a record."
        )
    }

    private func instruction(_ number: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(number)
                .font(.headline.bold())
                .frame(width: 36, height: 36)
                .background(Color("DonorRedSoft"))
                .foregroundStyle(Color("DonorRed"))
                .clipShape(Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(Color("TextSecondary"))
            }
        }
        .accessibilityElement(children: .combine)
    }
}
