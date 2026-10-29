//
//  DonationCountdownProgressCalculatorTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/21/26.
//

import Foundation
import Testing
@testable import DonorMateSL

struct DonationCountdownProgressCalculatorTests {

    @Test
    func noRecordReturnsNil() {

        let progress =
            DonationCountdownProgressCalculator
                .progress(
                    for: nil,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 6,
                            day: 1
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(progress == nil)
    }

    @Test
    func missingRecordedDateUsesFourMonthInterval() throws {

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

        let progress =
            try #require(
                DonationCountdownProgressCalculator
                    .progress(
                        for: record,
                        currentDate:
                            makeDate(
                                year: 2026,
                                month: 5,
                                day: 18
                            ),
                        calendar:
                            makeCalendar()
                    )
            )

        #expect(progress == 0)
    }

    @Test
    func earlierRecordedDateCannotShortenProgressInterval() throws {

        let calendar = makeCalendar()

        let recordWithEarlyDate =
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
                        month: 6,
                        day: 18
                    )
            )

        let recordWithoutDate =
            makeRecord(
                donationDate:
                    makeDate(
                        year: 2026,
                        month: 5,
                        day: 18
                    ),
                nextPossibleDate: nil
            )

        let currentDate =
            makeDate(
                year: 2026,
                month: 7,
                day: 18
            )

        let earlyProgress =
            try #require(
                DonationCountdownProgressCalculator
                    .progress(
                        for: recordWithEarlyDate,
                        currentDate: currentDate,
                        calendar: calendar
                    )
            )

        let minimumProgress =
            try #require(
                DonationCountdownProgressCalculator
                    .progress(
                        for: recordWithoutDate,
                        currentDate: currentDate,
                        calendar: calendar
                    )
            )

        #expect(earlyProgress == minimumProgress)
    }

    @Test
    func laterRecordedDeferralExtendsProgressInterval() throws {

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
                        month: 10,
                        day: 18
                    )
            )

        let progress =
            try #require(
                DonationCountdownProgressCalculator
                    .progress(
                        for: record,
                        currentDate:
                            makeDate(
                                year: 2026,
                                month: 9,
                                day: 18
                            ),
                        calendar:
                            makeCalendar()
                    )
            )

        #expect(progress > 0)
        #expect(progress < 1)
    }

    @Test
    func effectiveThresholdProducesCompletedProgress() throws {

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

        let progress =
            try #require(
                DonationCountdownProgressCalculator
                    .progress(
                        for: record,
                        currentDate:
                            makeDate(
                                year: 2026,
                                month: 9,
                                day: 18
                            ),
                        calendar:
                            makeCalendar()
                    )
            )

        #expect(progress == 1)
    }

    @Test
    func dateAfterThresholdRemainsCompleted() throws {

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

        let progress =
            try #require(
                DonationCountdownProgressCalculator
                    .progress(
                        for: record,
                        currentDate:
                            makeDate(
                                year: 2026,
                                month: 10,
                                day: 20
                            ),
                        calendar:
                            makeCalendar()
                    )
            )

        #expect(progress == 1)
    }

    @Test
    func futureDonationDateReturnsNil() {

        let record =
            makeRecord(
                donationDate:
                    makeDate(
                        year: 2026,
                        month: 10,
                        day: 21
                    ),
                nextPossibleDate: nil
            )

        let progress =
            DonationCountdownProgressCalculator
                .progress(
                    for: record,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 10,
                            day: 20
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(progress == nil)
    }

    @Test
    func unsupportedDonationTypeReturnsNil() {

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

        let progress =
            DonationCountdownProgressCalculator
                .progress(
                    for: record,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 6,
                            day: 18
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(progress == nil)
    }

    private func makeRecord(
        donationDate: Date,
        nextPossibleDate: Date?
    ) -> DonationRecord {

        DonationRecord(
            date: donationDate,
            location: "Matara",
            donationType: "Whole blood",
            recordLabel: "Blood-bank record",
            recordReference: nil,
            nextPossibleDonationDate:
                nextPossibleDate
        )
    }

    private func makeCalendar(
        timeZoneIdentifier: String = "UTC"
    ) -> Calendar {

        var calendar =
            Calendar(
                identifier: .gregorian
            )

        calendar.timeZone =
            TimeZone(
                identifier:
                    timeZoneIdentifier
            )!

        return calendar
    }

    private func makeDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 12,
        calendar: Calendar? = nil
    ) -> Date {

        let selectedCalendar =
            calendar
            ?? makeCalendar()

        return selectedCalendar.date(
            from: DateComponents(
                year: year,
                month: month,
                day: day,
                hour: hour
            )
        )!
    }
}
