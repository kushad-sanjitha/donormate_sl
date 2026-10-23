//
//  HomeDonorPresentationBuilderTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/21/26.
//

import Foundation
import Testing
@testable import DonorMateSL

struct HomeDonorPresentationBuilderTests {

    @Test
    func unlinkedDonorUsesGenericPresentation() {

        let presentation =
            HomeDonorPresentationBuilder
                .presentation(
                    linkState: .unlinked,
                    latestRecord: nil,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 10,
                            day: 21
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(
            presentation.isLinked == false
        )

        #expect(
            presentation.greeting ==
                "Welcome to DonorMate"
        )

        #expect(
            presentation.initials == nil
        )

        #expect(
            presentation.latestRecord == nil
        )

        #expect(
            presentation.reportedDonationCount == nil
        )

        #expect(
            presentation.readiness ==
                .unknown
        )

        #expect(
            presentation.countdownProgress == nil
        )
    }

    @Test
    func linkedDonorUsesFirstNameAndTwoInitials() {

        let profile =
            DonorProfile(
                displayName: "Sample Donor",
                bloodGroup: "A+",
                reportedDonationCount: 6
            )

        let presentation =
            HomeDonorPresentationBuilder
                .presentation(
                    linkState:
                        .linked(
                            profile: profile
                        ),
                    latestRecord: nil,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 10,
                            day: 21
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(
            presentation.isLinked
        )

        #expect(
            presentation.greeting ==
                "Hi, Sample"
        )

        #expect(
            presentation.initials ==
                "SD"
        )
    }

    @Test
    func extraWhitespaceDoesNotAffectNamePresentation() {

        let profile =
            DonorProfile(
                displayName:
                    "   Sample     Donor   ",
                bloodGroup: "A+",
                reportedDonationCount: 6
            )

        let presentation =
            HomeDonorPresentationBuilder
                .presentation(
                    linkState:
                        .linked(
                            profile: profile
                        ),
                    latestRecord: nil,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 10,
                            day: 21
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(
            presentation.greeting ==
                "Hi, Sample"
        )

        #expect(
            presentation.initials ==
                "SD"
        )
    }

    @Test
    func singleWordNameUsesSingleInitial() {

        let profile =
            DonorProfile(
                displayName: "John",
                bloodGroup: "A+",
                reportedDonationCount: 6
            )

        let presentation =
            HomeDonorPresentationBuilder
                .presentation(
                    linkState:
                        .linked(
                            profile: profile
                        ),
                    latestRecord: nil,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 10,
                            day: 21
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(
            presentation.greeting ==
                "Hi, John"
        )

        #expect(
            presentation.initials ==
                "J"
        )
    }

    @Test
    func blankDisplayNameUsesGenericGreetingWithoutInitials() {

        let profile =
            DonorProfile(
                displayName: "   ",
                bloodGroup: "A+",
                reportedDonationCount: 6
            )

        let presentation =
            HomeDonorPresentationBuilder
                .presentation(
                    linkState:
                        .linked(
                            profile: profile
                        ),
                    latestRecord: nil,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 10,
                            day: 21
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(
            presentation.isLinked
        )

        #expect(
            presentation.greeting ==
                "Welcome to DonorMate"
        )

        #expect(
            presentation.initials == nil
        )
    }

    @Test
    func reportedDonationCountIsPreserved() {

        let profile =
            DonorProfile(
                displayName: "Sample Donor",
                bloodGroup: "A+",
                reportedDonationCount: 6
            )

        let presentation =
            HomeDonorPresentationBuilder
                .presentation(
                    linkState:
                        .linked(
                            profile: profile
                        ),
                    latestRecord: nil,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 10,
                            day: 21
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(
            presentation.reportedDonationCount ==
                6
        )
    }

    @Test
    func unavailableReportedDonationCountRemainsNil() {

        let profile =
            DonorProfile(
                displayName: "Sample Donor",
                bloodGroup: "A+",
                reportedDonationCount: nil
            )

        let presentation =
            HomeDonorPresentationBuilder
                .presentation(
                    linkState:
                        .linked(
                            profile: profile
                        ),
                    latestRecord: nil,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 10,
                            day: 21
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(
            presentation.reportedDonationCount ==
                nil
        )
    }

    @Test
    func linkedDonorWithoutHistoryRemainsLinked() {

        let profile =
            DonorProfile(
                displayName: "Sample Donor",
                bloodGroup: "A+",
                reportedDonationCount: 0
            )

        let presentation =
            HomeDonorPresentationBuilder
                .presentation(
                    linkState:
                        .linked(
                            profile: profile
                        ),
                    latestRecord: nil,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 10,
                            day: 21
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(
            presentation.isLinked
        )

        #expect(
            presentation.greeting ==
                "Hi, Sample"
        )

        #expect(
            presentation.initials ==
                "SD"
        )

        #expect(
            presentation.latestRecord == nil
        )

        #expect(
            presentation.reportedDonationCount ==
                0
        )

        #expect(
            presentation.readiness ==
                .unknown
        )

        #expect(
            presentation.countdownProgress ==
                nil
        )
    }

    @Test
    func unlinkedStateDoesNotExposeUnexpectedRecord() {

        let record =
            makeRecord(
                donationDate:
                    makeDate(
                        year: 2026,
                        month: 5,
                        day: 18
                    ),
                nextPossibleDate:
                    makeDate(
                        year: 2026,
                        month: 9,
                        day: 18
                    )
            )

        let presentation =
            HomeDonorPresentationBuilder
                .presentation(
                    linkState:
                        .unlinked,
                    latestRecord: record,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 9,
                            day: 1
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(
            presentation.isLinked == false
        )

        #expect(
            presentation.greeting ==
                "Welcome to DonorMate"
        )

        #expect(
            presentation.initials == nil
        )

        #expect(
            presentation.latestRecord == nil
        )

        #expect(
            presentation.reportedDonationCount ==
                nil
        )

        #expect(
            presentation.readiness ==
                .unknown
        )

        #expect(
            presentation.countdownProgress ==
                nil
        )
    }

    @Test
    func linkedDonorBeforeThresholdIsNotReady() {

        let profile =
            DonorProfile(
                displayName: "Sample Donor",
                bloodGroup: "A+",
                reportedDonationCount: 6
            )

        let record =
            makeRecord(
                donationDate:
                    makeDate(
                        year: 2026,
                        month: 5,
                        day: 18
                    ),
                nextPossibleDate:
                    makeDate(
                        year: 2026,
                        month: 9,
                        day: 18
                    )
            )

        let presentation =
            HomeDonorPresentationBuilder
                .presentation(
                    linkState:
                        .linked(
                            profile: profile
                        ),
                    latestRecord: record,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 9,
                            day: 1
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(
            presentation.isLinked
        )

        #expect(
            presentation.readiness ==
                .notReady(
                    daysRemaining: 17
                )
        )

        #expect(
            presentation.countdownProgress !=
                nil
        )

        #expect(
            presentation.countdownProgress! > 0
        )

        #expect(
            presentation.countdownProgress! < 1
        )

        #expect(
            presentation.latestRecord?.date ==
                record.date
        )
    }

    @Test
    func demoRecordIsReadyAfterRecordedThreshold() {

        let profile =
            DonorProfile(
                displayName: "Sample Donor",
                bloodGroup: "A+",
                reportedDonationCount: 6
            )

        let record =
            makeRecord(
                donationDate:
                    makeDate(
                        year: 2026,
                        month: 5,
                        day: 18
                    ),
                nextPossibleDate:
                    makeDate(
                        year: 2026,
                        month: 9,
                        day: 18
                    )
            )

        let presentation =
            HomeDonorPresentationBuilder
                .presentation(
                    linkState:
                        .linked(
                            profile: profile
                        ),
                    latestRecord: record,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 10,
                            day: 21
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(
            presentation.isLinked
        )

        #expect(
            presentation.readiness ==
                .ready
        )

        #expect(
            presentation.countdownProgress ==
                1
        )

        #expect(
            presentation.latestRecord?.date ==
                record.date
        )
    }

    @Test
    func missingRecordedNextDateUsesDerivedMinimumReadiness() {

        let profile =
            DonorProfile(
                displayName: "Sample Donor",
                bloodGroup: "A+",
                reportedDonationCount: 6
            )

        let record =
            makeRecord(
                donationDate:
                    makeDate(
                        year: 2026,
                        month: 5,
                        day: 18
                    ),
                nextPossibleDate: nil
            )

        let presentation =
            HomeDonorPresentationBuilder
                .presentation(
                    linkState:
                        .linked(
                            profile: profile
                        ),
                    latestRecord: record,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 9,
                            day: 1
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(
            presentation.isLinked
        )

        #expect(
            presentation.latestRecord?.date ==
                record.date
        )

        #expect(
            presentation.readiness ==
                .notReady(
                    daysRemaining: 17
                )
        )

        #expect(
            presentation.countdownProgress !=
                nil
        )

        #expect(
            presentation.countdownProgress! > 0
        )

        #expect(
            presentation.countdownProgress! < 1
        )
    }

    private func makeRecord(
        donationDate: Date,
        nextPossibleDate: Date?
    ) -> DonationRecord {

        DonationRecord(
            date: donationDate,
            location: "Matara Blood Bank",
            donationType: "Whole blood",
            recordLabel: "Blood-bank record",
            recordReference: nil,
            nextPossibleDonationDate:
                nextPossibleDate
        )
    }

    private func makeCalendar() -> Calendar {

        var calendar =
            Calendar(
                identifier: .gregorian
            )

        calendar.timeZone =
            TimeZone(
                secondsFromGMT: 0
            )!

        return calendar
    }

    private func makeDate(
        year: Int,
        month: Int,
        day: Int
    ) -> Date {

        let calendar =
            makeCalendar()

        return calendar.date(
            from: DateComponents(
                year: year,
                month: month,
                day: day,
                hour: 12
            )
        )!
    }
}
