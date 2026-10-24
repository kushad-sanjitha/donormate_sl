//
//  UrgentNeedView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/20/26.
//

import SwiftUI

struct UrgentNeedView: View {

    let urgentNeed: UrgentBloodNeed
    let location: DonationLocation
    let presentation: UrgentNeedPresentation
    let distanceText: String

    let onDirections: () -> Void
    let onSave: (() -> Void)?
    let onRemind: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    private var locationDetail: String {
        let distance = distanceText.trimmingCharacters(in: .whitespacesAndNewlines)
        return distance.isEmpty ? location.name : "\(location.name) · \(distance)"
    }

    private var statusIcon: String {
        switch presentation.state {
        case .ready:
            "checkmark.circle.fill"
        case .waiting:
            "clock.fill"
        case .inactive, .unlinked, .bloodGroupUnavailable,
             .notMatching, .readinessUnknown:
            "info.circle.fill"
        }
    }

    private var statusColor: Color {
        switch presentation.state {
        case .ready:
            Color("SuccessGreen")
        case .waiting:
            Color("ReminderAmber")
        case .inactive, .unlinked, .bloodGroupUnavailable,
             .notMatching, .readinessUnknown:
            Color("InfoBlue")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenNavigationHeader(
                title: "Urgent Need",
                onBack: { dismiss() }
            )

            ScreenScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Text(urgentNeed.isDemonstration
                            ? "DEMO REQUEST"
                            : (presentation.isActive ? "URGENT" : "NOT ACTIVE"))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color("DonorRed"))
                            .padding(.horizontal, 10)
                            .frame(height: 28)
                            .background(Color("DonorRedSoft"))
                            .clipShape(Capsule())

                        Spacer()

                        Text(presentation.matchText)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color("TextSecondary"))
                    }

                    VStack(alignment: .leading, spacing: 7) {
                        Text(presentation.requestTitle)
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundStyle(Color("TextPrimary"))
                            .fixedSize(horizontal: false, vertical: true)

                        Text(locationDetail)
                            .font(.system(size: 13))
                            .foregroundStyle(Color("TextSecondary"))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: statusIcon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(statusColor)
                            .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(presentation.statusTitle)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color("TextPrimary"))

                            Text(presentation.statusDetail)
                                .font(.system(size: 13))
                                .foregroundStyle(Color("TextSecondary"))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("SurfacePrimary"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color("BorderPrimary"), lineWidth: 1)
                    }

                    VStack(spacing: 10) {
                        infoRow(
                            image: "drop.fill",
                            title: "Needed blood group",
                            value: urgentNeed.bloodGroup
                        )

                        infoRow(
                            image: "mappin.circle.fill",
                            title: "Location",
                            value: locationDetail
                        )

                        infoRow(
                            image: "clock.fill",
                            title: "Request status",
                            value: presentation.isActive
                                ? (urgentNeed.isDemonstration
                                    ? "Demonstration only · Not a live request"
                                    : "Active · Confirm with the blood bank")
                                : "Unavailable"
                        )
                    }

                    if presentation.canOfferDonationActions {
                        VStack(spacing: 10) {
                            actionButton("Get Directions", primary: true, action: onDirections)

                            if onSave != nil || onRemind != nil {
                                HStack(spacing: 10) {
                                    if let onSave {
                                        actionButton("Save", primary: false, action: onSave)
                                    }
                                    if let onRemind {
                                        actionButton("Remind Me", primary: false, action: onRemind)
                                    }
                                }
                            }
                        }
                    } else if case .waiting = presentation.state {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("What you can do")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Color("TextPrimary"))

                            if let onSave {
                                NeutralMessageCard(
                                    systemImage: "bookmark.fill",
                                    title: "Save this location",
                                    detail: "Keep this location for a future donation opportunity."
                                )
                                actionButton("Save Location", primary: false, action: onSave)
                            } else {
                                NeutralMessageCard(
                                    systemImage: "info.circle.fill",
                                    title: "Plan your next donation",
                                    detail: "You can review donation locations while your waiting period continues. Final eligibility is confirmed by blood-bank staff."
                                )
                            }
                            actionButton("Back to Home", primary: true) { dismiss() }
                        }
                    } else {
                        actionButton("Back", primary: true) { dismiss() }
                    }

                    NeutralMessageCard(
                        systemImage: "info.circle.fill",
                        title: urgentNeed.isDemonstration
                            ? "Demonstration request"
                            : "Request source",
                        detail: urgentNeed.sourceText,
                        style: .compact,
                        iconForeground: Color("InfoBlue")
                    )
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 18)
            }
        }
        .background(Color("BackgroundPrimary"))
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }

    private func infoRow(
        image: String,
        title: String,
        value: String
    ) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: image)
                .font(.system(size: 18))
                .foregroundStyle(Color("DonorRed"))
                .frame(width: 32)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(Color("TextSecondary"))

                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color("TextPrimary"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("SurfacePrimary"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("BorderPrimary"), lineWidth: 1)
        }
    }

    private func actionButton(
        _ title: String,
        primary: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(primary ? Color.white : Color("TextPrimary"))
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(primary ? Color("DonorRed") : Color("SurfacePrimary"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(primary ? Color.clear : Color("BorderPrimary"), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}

private struct UrgentNeedPreview: View {

    let readiness: DonationReadinessState

    private var urgentNeed: UrgentBloodNeed {
        UrgentBloodNeedCatalog.urgentNeeds[0]
    }

    private var location: DonationLocation {
        DonationLocationCatalog.location(for: urgentNeed.locationID) ??
            DonationLocation(
                id: urgentNeed.locationID,
                name: "Matara Blood Bank",
                type: .bloodBank,
                latitude: 5.9497,
                longitude: 80.5428,
                detail: "Location details unavailable"
            )
    }

    var body: some View {
        NavigationStack {
            UrgentNeedView(
                urgentNeed: urgentNeed,
                location: location,
                presentation: UrgentNeedPresentationBuilder.presentation(
                    for: urgentNeed,
                    linkState: .linked(profile: DonorDemoData.profile),
                    readiness: readiness,
                    currentDate: urgentNeed.publishedAt.addingTimeInterval(3_600)
                ),
                distanceText: "2.8 km",
                onDirections: {},
                onSave: {},
                onRemind: {}
            )
        }
    }
}

#Preview("Ready - Screen 27") {
    UrgentNeedPreview(readiness: .ready)
}

#Preview("Waiting - Screen 28") {
    UrgentNeedPreview(readiness: .notReady(daysRemaining: 17))
}
