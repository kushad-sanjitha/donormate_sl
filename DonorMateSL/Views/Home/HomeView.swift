//
//  HomeView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/8/26.
//

import SwiftUI
import Combine

struct HomeView: View {

    @Environment(\.scenePhase)
    private var scenePhase

    @ObservedObject var donorRecordsStore:
        DonorRecordsStore

    let accountProfile: AccountProfile

    var onConnectDonorRecord: () -> Void = {}
    var onFindNearby: () -> Void = {}

    @State private var currentDate = Date()

    private let calendar = Calendar.current

    private let dayRefreshTimer =
        Timer.publish(
            every: 60,
            on: .main,
            in: .common
        )
        .autoconnect()

    private var presentation:
        HomeDonorPresentation {

        HomeDonorPresentationBuilder
            .presentation(
                linkState:
                    donorRecordsStore.linkState,
                latestRecord:
                    donorRecordsStore.latestRecord,
                currentDate:
                    currentDate,
                calendar:
                    calendar
            )
    }


    private var accountGreeting: String {

        let nameParts =
            accountProfile.displayName
                .split {
                    $0.isWhitespace
                }

        guard let firstName =
                nameParts.first else {

            return "Welcome to DonorMate"
        }

        return "Hi, \(firstName)"
    }

    private var accountInitials: String? {

        let nameParts =
            accountProfile.displayName
                .split {
                    $0.isWhitespace
                }

        guard !nameParts.isEmpty else {
            return nil
        }

        return nameParts
            .prefix(2)
            .compactMap {
                $0.first
            }
            .map {
                    String($0)
                }
            .joined()
            .uppercased()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                homeHeader
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .padding(.bottom, 16)
                    .background(Color("BackgroundPrimary"))

                ScreenScrollView {
                    VStack(spacing: 0) {
                        donorStatusContent

                        if presentation.isLinked,
                           presentation.latestRecord != nil {

                            Spacer()
                                .frame(height: 14)

                            donationMetrics
                        }

                        additionalHomeContent

                        Spacer()
                            .frame(height: 28)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                }
            }
            .background(Color("BackgroundPrimary"))
        }
        .tabBarContentClearance()
        .onChange(of: scenePhase) {
            _, newPhase in

            if newPhase == .active {
                currentDate = Date()
            }
        }
        .onReceive(dayRefreshTimer) {
            date in

            if !calendar.isDate(
                date,
                inSameDayAs: currentDate
            ) {
                currentDate = date
            }
        }
    }

    private var homeHeader: some View {

        HStack(alignment: .center) {

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text("Good morning")
                    .font(
                        .system(size: 12)
                    )
                    .foregroundStyle(
                        Color("TextSecondary")
                    )

                Text(
                    accountGreeting
                )
                .font(
                    .system(
                        size: 20,
                        weight: .heavy
                    )
                )
                .foregroundStyle(
                    Color("TextPrimary")
                )
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(
                        Color("DonorRedSoft")
                    )
                    .frame(
                        width: 40,
                        height: 40
                    )

                if let initials =
                    accountInitials {

                    Text(initials)
                        .font(
                            .system(
                                size: 13,
                                weight: .heavy
                            )
                        )
                        .foregroundStyle(
                            Color("DonorRed")
                        )

                } else {

                    Image(
                        systemName: "drop.fill"
                    )
                    .font(
                        .system(
                            size: 15,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        Color("DonorRed")
                    )
                    .accessibilityHidden(true)
                }
            }
        }
    }

    @ViewBuilder
    private var donorStatusContent:
        some View {

        if !presentation.isLinked {

            unlinkedDonorContent

        } else if presentation.latestRecord == nil {

            linkedWithoutHistoryContent

        } else {

            switch presentation.readiness {

            case let .notReady(
                daysRemaining
            ):

                if let latestRecord =
                        presentation.latestRecord,
                   let nextPossibleDate =
                        DonationWaitingPeriodPolicy
                            .effectiveNextPossibleDonationDate(
                                for: latestRecord
                            ),
                   let progress =
                        presentation
                            .countdownProgress {

                    DonationCountdownCard(
                        daysRemaining:
                            daysRemaining,
                        nextPossibleDate:
                            formattedFullDate(
                                nextPossibleDate
                            ),
                        progress:
                            progress
                    )

                } else {

                    unknownReadinessCard
                }

            case .ready:

                HomeReadyCard(
                    onFindOpportunity: {
                        print(
                            "Find opportunity tapped"
                        )
                    }
                )

            case .unknown:

                unknownReadinessCard
            }
        }
    }

    private var unlinkedDonorContent:
        some View {

        VStack(
            alignment: .leading,
            spacing: 0
        ) {

            NeutralMessageCard(
                systemImage:
                    "person.crop.circle.badge.questionmark",
                title:
                    "No donor record linked",
                detail:
                    "Connect your donor record to see your donation history and recorded waiting-period status."
            )

            Spacer()
                .frame(height: 14)

            Button {
                onConnectDonorRecord()
            } label: {
                Text(
                    "Connect Donor Record"
                )
                .font(
                    .system(
                        size: 15,
                        weight: .bold
                    )
                )
                .foregroundStyle(.white)
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

    private var linkedWithoutHistoryContent:
        some View {

        NeutralMessageCard(
            systemImage: "clock.fill",
            title:
                "No donation history available",
            detail:
                "Your donor record is connected, but there is no recorded donation available to calculate your waiting-period status."
        )
    }

    private var unknownReadinessCard:
        some View {

        NeutralMessageCard(
            systemImage:
                "questionmark.circle.fill",
            title:
                "Waiting-period status unavailable",
            detail:
                "DonorMate cannot calculate your recorded waiting period from the available donation information."
        )
    }

    private var donationMetrics:
        some View {

        HStack(
            alignment: .top,
            spacing: 10
        ) {

            SummaryMetricCard(
                title:
                    "Last donation",
                value:
                    latestDonationValue,
                detail:
                    latestDonationLocation
            )

            SummaryMetricCard(
                title:
                    "Recorded donations",
                value:
                    reportedDonationValue,
                detail:
                    reportedDonationDetail
            )
        }
    }

    private var latestDonationValue:
        String {

        guard let latestRecord =
                presentation.latestRecord else {
            return "—"
        }

        return latestRecord.date.formatted(
            Date.FormatStyle()
                .day()
                .month(.abbreviated)
                .locale(
                    Locale(
                        identifier: "en_GB"
                    )
                )
        )
    }

    private var latestDonationLocation:
        String {

        guard let latestRecord =
                presentation.latestRecord else {
            return "Unavailable"
        }

        return latestRecord.location
    }

    private var reportedDonationValue:
        String {

        guard let count =
                presentation
                    .reportedDonationCount else {
            return "—"
        }

        return String(count)
    }

    private var reportedDonationDetail:
        String {

        if presentation
            .reportedDonationCount == nil {
            return "Total unavailable"
        }

        return "Linked record"
    }

    @ViewBuilder
    private var additionalHomeContent:
        some View {

        if presentation.isLinked {

            switch presentation.readiness {

            case .notReady:

                notReadyAdditionalContent

            case .ready:

                readyAdditionalContent

            case .unknown:

                linkedUnknownAdditionalContent
            }
        }
    }

    private var notReadyAdditionalContent:
        some View {

        VStack(spacing: 0) {

            Spacer()
                .frame(height: 16)

            HStack(
                alignment: .center
            ) {

                Text("Nearby this week")
                    .font(
                        .system(
                            size: 15,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        Color("TextPrimary")
                    )

                Spacer()

                Button {
                    print(
                        "See all tapped"
                    )
                } label: {
                    Text("See all")
                        .font(
                            .system(
                                size: 13,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(
                            Color("DonorRed")
                        )
                }
                .buttonStyle(.plain)
            }

            Spacer()
                .frame(height: 8)

            HomeInfoRow(
                title:
                    "Matara Donation Camp",
                detail:
                    "Sat · 9:00 AM · 2.4 km",
                systemImage:
                    "location.fill",
                iconBackground:
                    Color("InfoBlueSoft"),
                iconForeground:
                    Color("InfoBlue")
            )

            Spacer()
                .frame(height: 16)

            quickActions
        }
    }

    private var readyAdditionalContent:
        some View {

        VStack(spacing: 0) {

            Spacer()
                .frame(height: 16)

            HStack(
                alignment: .center
            ) {

                Text(
                    "Closest opportunity"
                )
                .font(
                    .system(
                        size: 15,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    Color("TextPrimary")
                )

                Spacer()

                Button {
                    print(
                        "View map tapped"
                    )
                } label: {
                    Text("View map")
                        .font(
                            .system(
                                size: 13,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(
                            Color("DonorRed")
                        )
                }
                .buttonStyle(.plain)
            }

            Spacer()
                .frame(height: 8)

            HomeInfoRow(
                title:
                    "Matara Blood Bank",
                detail:
                    "Open today · 2.1 km",
                systemImage:
                    "location.fill",
                iconBackground:
                    Color("InfoBlueSoft"),
                iconForeground:
                    Color("InfoBlue")
            )

            Spacer()
                .frame(height: 14)

            NeutralMessageCard(
                systemImage:
                    "info.circle.fill",
                title:
                    "Final eligibility is confirmed by staff.",
                detail:
                    "DonorMate only tracks the recorded waiting period.",
                style: .compact
            )
        }
    }

    private var linkedUnknownAdditionalContent:
        some View {

        VStack(spacing: 0) {

            Spacer()
                .frame(height: 16)

            quickActions
        }
    }

    private var quickActions:
        some View {

        VStack(spacing: 0) {

            Text("Quick actions")
                .font(
                    .system(
                        size: 15,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    Color("TextPrimary")
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

            Spacer()
                .frame(height: 8)

            HStack(
                alignment: .top,
                spacing: 10
            ) {

                NavigationLink {
                    DonationReadinessView(
                        donorRecordsStore:
                            donorRecordsStore,
                        onFindNearby:
                            onFindNearby
                    )
                } label: {
                    HomeQuickActionCard(
                        title:
                            "View Readiness",
                        systemImage:
                            "checkmark.circle.fill",
                        iconBackground:
                            Color(
                                "SuccessGreenSoft"
                            ),
                        iconForeground:
                            Color(
                                "SuccessGreen"
                            )
                    )
                }
                .buttonStyle(.plain)

                HomeQuickActionCard(
                    title:
                        "Find Nearby",
                    systemImage:
                        "map.fill",
                    iconBackground:
                        Color(
                            "InfoBlueSoft"
                        ),
                    iconForeground:
                        Color(
                            "InfoBlue"
                        )
                )
            }
        }
    }

    private func formattedFullDate(
        _ date: Date
    ) -> String {

        date.formatted(
            Date.FormatStyle()
                .day()
                .month(.wide)
                .year()
                .locale(
                    Locale(
                        identifier: "en_GB"
                    )
                )
        )
    }
}

#Preview("Linked Demo Donor") {
    HomeView(
        donorRecordsStore:
            DonorRecordsStore(
                linkState:
                    .linked(
                        profile:
                            DonorDemoData.profile
                    ),
                records:
                    DonorDemoData.records
            ),
        accountProfile:
            AccountProfile(
                uid: "preview-user",
                displayName: "Kushad Dissanayake",
                email: "kushad@example.com"
            )
    )
}

#Preview("Unlinked Donor") {
    HomeView(
        donorRecordsStore:
            DonorRecordsStore(),
        accountProfile:
            AccountProfile(
                uid: "preview-user",
                displayName: "Kushad Dissanayake",
                email: "kushad@example.com"
            )
    )
}

#Preview("Linked Without History") {
    HomeView(
        donorRecordsStore:
            DonorRecordsStore(
                linkState:
                    .linked(
                        profile:
                            DonorDemoData.profile
                    ),
                records: []
            ),
        accountProfile:
            AccountProfile(
                uid: "preview-user",
                displayName: "Kushad Dissanayake",
                email: "kushad@example.com"
            )
    )
}
