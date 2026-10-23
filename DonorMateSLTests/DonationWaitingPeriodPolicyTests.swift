//
//  DonationWaitingPeriodPolicyTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/23/26.
//

import Foundation
import Testing
@testable import DonorMateSL

struct DonationWaitingPeriodPolicyTests {

    private var calendar: Calendar {
        var calendar =
            Calendar(
                identifier: .gregorian
            )

        calendar.timeZone =
            TimeZone(
                identifier: "Asia/Colombo"
            )!

        return calendar
    }

    @Test
    func derivesFourCalendarMonthsWhenRecordedDateIsMissing() throws {

        let effectiveDate =
            try #require(
                DonationWaitingPeriodPolicy
                    .effectiveNextPossibleDonationDate(
                        for:
                            makeRecord(
                                donationDate:
                                    makeDate(
                                        year: 2026,
                                        month: 9,
                                        day: 10
                                    ),
                                recordedDate: nil
                            ),
                        calendar: calendar
                    )
            )

        #expect(
            calendar.isDate(
                effectiveDate,
                inSameDayAs:
                    makeDate(
                        year: 2027,
                        month: 1,
                        day: 10
                    )
            )
        )
    }

    @Test
    func recordedEarlierDateCannotShortenMinimum() throws {

        let effectiveDate =
            try #require(
                DonationWaitingPeriodPolicy
                    .effectiveNextPossibleDonationDate(
                        for:
                            makeRecord(
                                donationDate:
                                    makeDate(
                                        year: 2026,
                                        month: 5,
                                        day: 18
                                    ),
                                recordedDate:
                                    makeDate(
                                        year: 2026,
                                        month: 6,
                                        day: 18
                                    )
                            ),
                        calendar: calendar
                    )
            )

        #expect(
            calendar.isDate(
                effectiveDate,
                inSameDayAs:
                    makeDate(
                        year: 2026,
                        month: 9,
                        day: 18
                    )
            )
        )
    }

    @Test
    func laterRecordedDeferralWins() throws {

        let effectiveDate =
            try #require(
                DonationWaitingPeriodPolicy
                    .effectiveNextPossibleDonationDate(
                        for:
                            makeRecord(
                                donationDate:
                                    makeDate(
                                        year: 2026,
                                        month: 5,
                                        day: 18
                                    ),
                                recordedDate:
                                    makeDate(
                                        year: 2026,
                                        month: 10,
                                        day: 18
                                    )
                            ),
                        calendar: calendar
                    )
            )

        #expect(
            calendar.isDate(
                effectiveDate,
                inSameDayAs:
                    makeDate(
                        year: 2026,
                        month: 10,
                        day: 18
                    )
            )
        )
    }

    @Test
    func unsupportedDonationTypeHasNoPolicyDate() {

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
                recordLabel: "Blood-bank record",
                recordReference: nil,
                nextPossibleDonationDate: nil
            )

        #expect(
            DonationWaitingPeriodPolicy
                .effectiveNextPossibleDonationDate(
                    for: record,
                    calendar: calendar
                ) == nil
        )
    }

    private func makeRecord(
        donationDate: Date,
        recordedDate: Date?
    ) -> DonationRecord {

        DonationRecord(
            date: donationDate,
            location: "Matara Blood Bank",
            donationType: "Whole blood",
            recordLabel: "Blood-bank record",
            recordReference: nil,
            nextPossibleDonationDate:
                recordedDate
        )
    }

    private func makeDate(
        year: Int,
        month: Int,
        day: Int
    ) -> Date {

        calendar.date(
            from: DateComponents(
                year: year,
                month: month,
                day: day,
                hour: 12
            )
        )!
    }
}
