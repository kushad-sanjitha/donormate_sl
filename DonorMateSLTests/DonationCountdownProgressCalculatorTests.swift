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
                            month: 1,
                            day: 5
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(
            progress == nil
        )
    }

    @Test
    func missingNextPossibleDateReturnsNil() {

        let record =
            makeRecord(
                donationDate:
                    makeDate(
                        year: 2026,
                        month: 1,
                        day: 1
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
                            month: 1,
                            day: 5
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(
            progress == nil
        )
    }

    @Test
    func futureDonationDateReturnsNil() {

        let record =
            makeRecord(
                donationDate:
                    makeDate(
                        year: 2026,
                        month: 1,
                        day: 10
                    ),
                nextPossibleDate:
                    makeDate(
                        year: 2026,
                        month: 1,
                        day: 20
                    )
            )

        let progress =
            DonationCountdownProgressCalculator
                .progress(
                    for: record,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 1,
                            day: 5
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(
            progress == nil
        )
    }

    @Test
    func nextPossibleDateBeforeDonationDateReturnsNil() {

        let record =
            makeRecord(
                donationDate:
                    makeDate(
                        year: 2026,
                        month: 1,
                        day: 10
                    ),
                nextPossibleDate:
                    makeDate(
                        year: 2026,
                        month: 1,
                        day: 5
                    )
            )

        let progress =
            DonationCountdownProgressCalculator
                .progress(
                    for: record,
                    currentDate:
                        makeDate(
                            year: 2026,
                            month: 1,
                            day: 10
                        ),
                    calendar:
                        makeCalendar()
                )

        #expect(
            progress == nil
        )
    }

    @Test
    func donationDayStartsAtZeroProgress() throws {

        let record =
            makeRecord(
                donationDate:
                    makeDate(
                        year: 2026,
                        month: 1,
                        day: 1
                    ),
                nextPossibleDate:
                    makeDate(
                        year: 2026,
                        month: 1,
                        day: 11
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
                                month: 1,
                                day: 1
                            ),
                        calendar:
                            makeCalendar()
                    )
            )

        #expect(
            progress == 0
        )
    }

    @Test
    func midpointProducesHalfProgress() throws {

        let record =
            makeRecord(
                donationDate:
                    makeDate(
                        year: 2026,
                        month: 1,
                        day: 1
                    ),
                nextPossibleDate:
                    makeDate(
                        year: 2026,
                        month: 1,
                        day: 11
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
                                month: 1,
                                day: 6
                            ),
                        calendar:
                            makeCalendar()
                    )
            )

        #expect(
            progress == 0.5
        )
    }

    @Test
    func thresholdDayProducesCompletedProgress() throws {

        let record =
            makeRecord(
                donationDate:
                    makeDate(
                        year: 2026,
                        month: 1,
                        day: 1
                    ),
                nextPossibleDate:
                    makeDate(
                        year: 2026,
                        month: 1,
                        day: 11
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
                                month: 1,
                                day: 11
                            ),
                        calendar:
                            makeCalendar()
                    )
            )

        #expect(
            progress == 1
        )
    }

    @Test
    func dateAfterThresholdRemainsCompleted() throws {

        let record =
            makeRecord(
                donationDate:
                    makeDate(
                        year: 2026,
                        month: 1,
                        day: 1
                    ),
                nextPossibleDate:
                    makeDate(
                        year: 2026,
                        month: 1,
                        day: 11
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
                                month: 1,
                                day: 20
                            ),
                        calendar:
                            makeCalendar()
                    )
            )

        #expect(
            progress == 1
        )
    }

    @Test
    func sameDayDonationAndNextPossibleDateReturnsNil() {

        let date =
            makeDate(
                year: 2026,
                month: 1,
                day: 1
            )

        let record =
            makeRecord(
                donationDate: date,
                nextPossibleDate: date
            )

        let progress =
            DonationCountdownProgressCalculator
                .progress(
                    for: record,
                    currentDate: date,
                    calendar:
                        makeCalendar()
                )

        #expect(
            progress == nil
        )
    }

    @Test
    func leapYearDatesUseCalendarDayProgress() throws {

        let record =
            makeRecord(
                donationDate:
                    makeDate(
                        year: 2028,
                        month: 2,
                        day: 28
                    ),
                nextPossibleDate:
                    makeDate(
                        year: 2028,
                        month: 3,
                        day: 1
                    )
            )

        let progress =
            try #require(
                DonationCountdownProgressCalculator
                    .progress(
                        for: record,
                        currentDate:
                            makeDate(
                                year: 2028,
                                month: 2,
                                day: 29
                            ),
                        calendar:
                            makeCalendar()
                    )
            )

        #expect(
            progress == 0.5
        )
    }

    @Test
    func asiaColomboCalendarUsesLocalCalendarDays() throws {

        let calendar =
            makeCalendar(
                timeZoneIdentifier:
                    "Asia/Colombo"
            )

        let record =
            makeRecord(
                donationDate:
                    makeDate(
                        year: 2026,
                        month: 5,
                        day: 18,
                        hour: 1,
                        calendar: calendar
                    ),
                nextPossibleDate:
                    makeDate(
                        year: 2026,
                        month: 5,
                        day: 20,
                        hour: 23,
                        calendar: calendar
                    )
            )

        let currentDate =
            makeDate(
                year: 2026,
                month: 5,
                day: 19,
                hour: 22,
                calendar: calendar
            )

        let progress =
            try #require(
                DonationCountdownProgressCalculator
                    .progress(
                        for: record,
                        currentDate: currentDate,
                        calendar: calendar
                    )
            )

        #expect(
            progress == 0.5
        )
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
