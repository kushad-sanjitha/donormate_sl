//
//  DonationReadinessPresentationBuilderTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/22/26.
//

import Foundation
import Testing
@testable import DonorMateSL

struct DonationReadinessPresentationBuilderTests {

    private let calendar = testCalendar()

    @Test
    func unlinkedDonorShowsUnavailableState() {

        let presentation =
            DonationReadinessPresentationBuilder
                .presentation(
                    linkState: .unlinked,
                    latestRecord: nil,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 10,
                            day: 22
                        ),
                    calendar: calendar
                )

        #expect(
            presentation.style == .neutral
        )
        #expect(
            presentation.title ==
                "Readiness unavailable"
        )
    }

    @Test
    func linkedDonorWithoutHistoryShowsUnknownState() {

        let presentation =
            DonationReadinessPresentationBuilder
                .presentation(
                    linkState:
                        .linked(
                            profile:
                                DonorProfile(
                                    displayName:
                                        "Sample Donor",
                                    bloodGroup: "A+",
                                    reportedDonationCount: 0
                                )
                        ),
                    latestRecord: nil,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 10,
                            day: 22
                        ),
                    calendar: calendar
                )

        #expect(
            presentation.style == .neutral
        )
        #expect(
            presentation.title ==
                "Waiting-period status unavailable"
        )
    }

    @Test
    func notReadyUsesCalculatedRemainingDays() {

        let record =
            DonationRecord(
                date:
                    makeDate(
                        year: 2026,
                        month: 5,
                        day: 18
                    ),
                location: "Matara",
                donationType: "Whole blood",
                recordLabel: "Test record",
                recordReference: nil,
                nextPossibleDonationDate:
                    makeDate(
                        year: 2026,
                        month: 9,
                        day: 18
                    )
            )

        let presentation =
            DonationReadinessPresentationBuilder
                .presentation(
                    linkState:
                        .linked(
                            profile:
                                DonorProfile(
                                    displayName:
                                        "Sample Donor",
                                    bloodGroup: "A+",
                                    reportedDonationCount: 1
                                )
                        ),
                    latestRecord: record,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 8,
                            day: 25
                        ),
                    calendar: calendar
                )

        #expect(
            presentation.style == .warning
        )
        #expect(
            presentation.title ==
                "24 days remaining"
        )
        #expect(
            presentation.compactMessage.contains(
                "24 days"
            )
        )
    }

    @Test
    func readyStateUsesLatestRecordedDonationDate() {

        let record =
            DonationRecord(
                date:
                    makeDate(
                        year: 2026,
                        month: 5,
                        day: 18
                    ),
                location: "Matara",
                donationType: "Whole blood",
                recordLabel: "Test record",
                recordReference: nil,
                nextPossibleDonationDate:
                    makeDate(
                        year: 2026,
                        month: 9,
                        day: 18
                    )
            )

        let presentation =
            DonationReadinessPresentationBuilder
                .presentation(
                    linkState:
                        .linked(
                            profile:
                                DonorProfile(
                                    displayName:
                                        "Sample Donor",
                                    bloodGroup: "A+",
                                    reportedDonationCount: 1
                                )
                        ),
                    latestRecord: record,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 10,
                            day: 22
                        ),
                    calendar: calendar
                )

        #expect(
            presentation.style == .success
        )
        #expect(
            presentation.title ==
                "Minimum wait completed"
        )
        #expect(
            presentation.detail.contains(
                "18 May 2026"
            )
        )
    }

    @Test
    func unsupportedDonationTypeShowsUnknownState() {

        let record =
            DonationRecord(
                date:
                    makeDate(
                        year: 2026,
                        month: 5,
                        day: 18
                    ),
                location: "Matara",
                donationType: "Platelets",
                recordLabel: "Test record",
                recordReference: nil,
                nextPossibleDonationDate: nil
            )

        let presentation =
            DonationReadinessPresentationBuilder
                .presentation(
                    linkState:
                        .linked(
                            profile:
                                DonorProfile(
                                    displayName:
                                        "Sample Donor",
                                    bloodGroup: "A+",
                                    reportedDonationCount: 1
                                )
                        ),
                    latestRecord: record,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 10,
                            day: 22
                        ),
                    calendar: calendar
                )

        #expect(
            presentation.style == .neutral
        )
        #expect(
            presentation.title ==
                "Waiting-period status unavailable"
        )
    }
}

private func testCalendar() -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(
        identifier: "Asia/Colombo"
    )!
    return calendar
}

private func makeDate(
    year: Int,
    month: Int,
    day: Int
) -> Date {
    testCalendar().date(
        from:
            DateComponents(
                year: year,
                month: month,
                day: day
            )
    )!
}
