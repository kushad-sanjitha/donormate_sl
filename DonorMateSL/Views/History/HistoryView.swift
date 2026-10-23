//
//  HistoryView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/8/26.
//

import SwiftUI

struct HistoryView: View {

    private enum HistoryPresentationState {
        case unlinked
        case linkedEmpty
        case populated
    }

    @ObservedObject var donorRecordsStore:
        DonorRecordsStore

    var onConnectDonorRecord: () -> Void = {}

    private var presentationState:
        HistoryPresentationState {

        switch donorRecordsStore.linkState {

        case .unlinked:
            return .unlinked

        case .linked:
            if donorRecordsStore.records.isEmpty {
                return .linkedEmpty
            }

            return .populated
        }
    }

    private var latestDonationDayMonth: String {

        guard let latestRecord =
                donorRecordsStore.latestRecord else {
            return "—"
        }

        return latestRecord.date.formatted(
            Date.FormatStyle()
                .day()
                .month(.abbreviated)
                .locale(
                    Locale(identifier: "en_GB")
                )
        )
    }

    private var latestDonationYear: String {

        guard let latestRecord =
                donorRecordsStore.latestRecord else {
            return ""
        }

        return latestRecord.date.formatted(
            Date.FormatStyle()
                .year()
                .locale(
                    Locale(identifier: "en_GB")
                )
        )
    }

    private var reportedDonationValue: String {

        guard let count =
                donorRecordsStore
                    .reportedDonationCount else {
            return "—"
        }

        return String(count)
    }

    private var reportedDonationDetail: String {

        if donorRecordsStore
            .reportedDonationCount == nil {
            return "Total unavailable"
        }

        return "Linked record"
    }

    var body: some View {
        NavigationStack {
            Group {
                switch presentationState {

                case .unlinked:
                    ScreenScrollView {
                        emptyHistoryContent(
                            title:
                                "No linked donations yet",
                            description:
                                "Your donation history will appear here when a donor record is connected and records are available.",
                            informationTitle:
                                "Read-only records",
                            informationDetail:
                                "Linked donation records can be viewed in DonorMate, but they cannot be created or edited here.",
                            showsConnectAction:
                                true
                        )
                        .padding(.horizontal, 18)
                        .padding(.top, 18)
                    }

                case .linkedEmpty:
                    ScreenScrollView {
                        emptyHistoryContent(
                            title:
                                "No donation records yet",
                            description:
                                "Your donor record is connected, but no donation history is currently available.",
                            informationTitle:
                                "No records available",
                            informationDetail:
                                "Donation records will appear here when they are supplied by the connected donor-record service.",
                            showsConnectAction:
                                false
                        )
                        .padding(.horizontal, 18)
                        .padding(.top, 18)
                    }

                case .populated:
                    VStack(spacing: 0) {
                        populatedHistoryHeader

                        ScrollView {
                            populatedHistoryRows
                                .padding(.horizontal, 18)
                                .padding(.bottom, 20)
                        }
                        .scrollDismissesKeyboard(.interactively)
                    }
                }
            }
            .background(
                Color("BackgroundPrimary")
            )
        }
        .tabBarContentClearance()
    }

    private var populatedHistoryHeader: some View {

        VStack(spacing: 0) {
            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text("Your donation records")
                    .font(
                        .system(size: 12)
                    )
                    .foregroundStyle(
                        Color("TextSecondary")
                    )

                Text("Donation History")
                    .font(
                        .system(
                            size: 24,
                            weight: .heavy
                        )
                    )
                    .foregroundStyle(
                        Color("TextPrimary")
                    )
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )

            Spacer()
                .frame(height: 8)

            InfoMessageCard(
                systemImage: "info.circle.fill",
                title: "Demonstration records",
                detail: "These records are provided for demonstration and are not verified blood-bank records."
            )

            Spacer()
                .frame(height: 14)

            HStack(
                alignment: .top,
                spacing: 10
            ) {

                SummaryMetricCard(
                    title: "Total donations",
                    value: reportedDonationValue,
                    detail: reportedDonationDetail
                )

                SummaryMetricCard(
                    title: "Latest donation",
                    value: latestDonationDayMonth,
                    detail: latestDonationYear
                )
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 16)
        .background(Color("BackgroundPrimary"))
        .zIndex(1)
    }

    private var populatedHistoryRows: some View {

        let records =
            donorRecordsStore
                .recordsNewestFirst

        return VStack(spacing: 0) {
            ForEach(
                records.indices,
                id: \.self
            ) { index in

                let record =
                    records[index]

                NavigationLink {
                    DonationDetailView(
                        record: record
                    )
                } label: {
                    DonationHistoryRow(
                        record: record,
                        isLast:
                            index ==
                            records.count - 1
                    )
                    .contentShape(
                        Rectangle()
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func emptyHistoryContent(
        title: String,
        description: String,
        informationTitle: String,
        informationDetail: String,
        showsConnectAction: Bool
    ) -> some View {

        VStack(spacing: 0) {

            historyTitle

            Spacer()
                .frame(height: 82)

            EmptyStateIllustration(
                systemImage: "book.fill"
            )
            .frame(
                maxWidth: .infinity,
                alignment: .center
            )

            Spacer()
                .frame(height: 10)

            Text(title)
                .font(
                    .system(
                        size: 20,
                        weight: .heavy
                    )
                )
                .foregroundStyle(
                    Color("TextPrimary")
                )
                .multilineTextAlignment(
                    .center
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )

            Spacer()
                .frame(height: 10)

            Text(description)
                .font(
                    .system(size: 14)
                )
                .foregroundStyle(
                    Color("TextSecondary")
                )
                .multilineTextAlignment(
                    .center
                )
                .lineSpacing(3)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )

            Spacer()
                .frame(height: 18)

            InfoMessageCard(
                systemImage: "cloud.fill",
                title: informationTitle,
                detail: informationDetail
            )

            if showsConnectAction {

                Spacer()
                    .frame(height: 18)

                Button {
                    onConnectDonorRecord()
                } label: {
                    Text("Connect Donor Record")
                        .font(
                            .system(
                                size: 15,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(
                            .white
                        )
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 48
                        )
                        .background(
                            Color("DonorRed")
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 14
                            )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var historyTitle: some View {

        Text("Donation History")
            .font(
                .system(
                    size: 24,
                    weight: .heavy
                )
            )
            .foregroundStyle(
                Color("TextPrimary")
            )
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
    }
}

#Preview("Linked Demo History") {
    HistoryView(
        donorRecordsStore:
            DonorRecordsStore(
                linkState: .linked(
                    profile:
                        DonorDemoData.profile
                ),
                records:
                    DonorDemoData.records
            ),
        onConnectDonorRecord: {
            print(
                "Connect Donor Record tapped"
            )
        }
    )
}

#Preview("Unlinked History") {
    HistoryView(
        donorRecordsStore:
            DonorRecordsStore(),
        onConnectDonorRecord: {
            print(
                "Connect Donor Record tapped"
            )
        }
    )
}

#Preview("Linked Empty History") {
    HistoryView(
        donorRecordsStore:
            DonorRecordsStore(
                linkState: .linked(
                    profile:
                        DonorDemoData.profile
                ),
                records: []
            )
    )
}
