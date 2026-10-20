//
//  DonationReadinessCalculatorTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/20/26.
//

import Foundation
import Testing
@testable import DonorMateSL

struct DonationReadinessCalculatorTests {

    private var calendar: Calendar {
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

    @Test
    func beforeThresholdReturnsSeventeenDaysRemaining() {

        let record =
            prototypeRecord()

        let currentDate =
            makeDate(
                year: 2026,
                month: 9,
                day: 1
            )

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate: currentDate,
                calendar: calendar
            )

        #expect(
            result ==
                .notReady(
                    daysRemaining: 17
                )
        )
    }

    @Test
    func oneDayBeforeThresholdReturnsOneDayRemaining() {

        let record =
            prototypeRecord()

        let currentDate =
            makeDate(
                year: 2026,
                month: 9,
                day: 17
            )

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate: currentDate,
                calendar: calendar
            )

        #expect(
            result ==
                .notReady(
                    daysRemaining: 1
                )
        )
    }

    @Test
    func thresholdDateReturnsReady() {

        let record =
            prototypeRecord()

        let currentDate =
            makeDate(
                year: 2026,
                month: 9,
                day: 18
            )

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate: currentDate,
                calendar: calendar
            )

        #expect(
            result == .ready
        )
    }

    @Test
    func dateAfterThresholdReturnsReady() {

        let record =
            prototypeRecord()

        let currentDate =
            makeDate(
                year: 2026,
                month: 10,
                day: 20
            )

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate: currentDate,
                calendar: calendar
            )

        #expect(
            result == .ready
        )
    }

    @Test
    func noRecordReturnsUnknown() {

        let currentDate =
            makeDate(
                year: 2026,
                month: 10,
                day: 20
            )

        let result =
            DonationReadinessCalculator.readiness(
                for: nil,
                currentDate: currentDate,
                calendar: calendar
            )

        #expect(
            result == .unknown
        )
    }

    @Test
    func missingNextPossibleDateReturnsUnknown() {

        let record =
            DonationRecord(
                date: makeDate(
                    year: 2026,
                    month: 5,
                    day: 18
                ),
                location: "Matara Blood Bank",
                donationType: "Whole blood",
                recordLabel: "Blood-bank record",
                recordReference: "DB-2026-0518-006",
                nextPossibleDonationDate: nil
            )

        let currentDate =
            makeDate(
                year: 2026,
                month: 10,
                day: 20
            )

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate: currentDate,
                calendar: calendar
            )

        #expect(
            result == .unknown
        )
    }

    @Test
    func futureDonationDateReturnsUnknown() {

        let record =
            DonationRecord(
                date: makeDate(
                    year: 2026,
                    month: 10,
                    day: 21
                ),
                location: "Matara Blood Bank",
                donationType: "Whole blood",
                recordLabel: "Blood-bank record",
                recordReference: "DB-2026-1021-001",
                nextPossibleDonationDate: makeDate(
                    year: 2027,
                    month: 2,
                    day: 21
                )
            )

        let currentDate =
            makeDate(
                year: 2026,
                month: 10,
                day: 20
            )

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate: currentDate,
                calendar: calendar
            )

        #expect(
            result == .unknown
        )
    }

    @Test
    func nextPossibleDateBeforeDonationDateReturnsUnknown() {

        let record =
            DonationRecord(
                date: makeDate(
                    year: 2026,
                    month: 5,
                    day: 18
                ),
                location: "Matara Blood Bank",
                donationType: "Whole blood",
                recordLabel: "Blood-bank record",
                recordReference: "DB-2026-0518-006",
                nextPossibleDonationDate: makeDate(
                    year: 2026,
                    month: 5,
                    day: 17
                )
            )

        let currentDate =
            makeDate(
                year: 2026,
                month: 5,
                day: 18
            )

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate: currentDate,
                calendar: calendar
            )

        #expect(
            result == .unknown
        )
    }

    @Test
    func differentHoursOnSameThresholdDateStillReturnsReady() {

        let record =
            DonationRecord(
                date: makeDate(
                    year: 2026,
                    month: 5,
                    day: 18,
                    hour: 18
                ),
                location: "Matara Blood Bank",
                donationType: "Whole blood",
                recordLabel: "Blood-bank record",
                recordReference: "DB-2026-0518-006",
                nextPossibleDonationDate: makeDate(
                    year: 2026,
                    month: 9,
                    day: 18,
                    hour: 23
                )
            )

        let currentDate =
            makeDate(
                year: 2026,
                month: 9,
                day: 18,
                hour: 1
            )

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate: currentDate,
                calendar: calendar
            )

        #expect(
            result == .ready
        )
    }

    @Test
    func leapYearBoundaryCalculatesCorrectDaysRemaining() {

        let record =
            DonationRecord(
                date: makeDate(
                    year: 2028,
                    month: 1,
                    day: 1
                ),
                location: "Matara Blood Bank",
                donationType: "Whole blood",
                recordLabel: "Blood-bank record",
                recordReference: "DB-2028-0101-001",
                nextPossibleDonationDate: makeDate(
                    year: 2028,
                    month: 3,
                    day: 1
                )
            )

        let currentDate =
            makeDate(
                year: 2028,
                month: 2,
                day: 28
            )

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate: currentDate,
                calendar: calendar
            )

        #expect(
            result ==
                .notReady(
                    daysRemaining: 2
                )
        )
    }

    @Test
    func yearBoundaryCalculatesCorrectDaysRemaining() {

        let record =
            DonationRecord(
                date: makeDate(
                    year: 2026,
                    month: 9,
                    day: 1
                ),
                location: "Matara Blood Bank",
                donationType: "Whole blood",
                recordLabel: "Blood-bank record",
                recordReference: "DB-2026-0901-001",
                nextPossibleDonationDate: makeDate(
                    year: 2027,
                    month: 1,
                    day: 2
                )
            )

        let currentDate =
            makeDate(
                year: 2026,
                month: 12,
                day: 31
            )

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate: currentDate,
                calendar: calendar
            )

        #expect(
            result ==
                .notReady(
                    daysRemaining: 2
                )
        )
    }

    @Test
    func daylightSavingBoundaryUsesCalendarDays() {

        var newYorkCalendar =
            Calendar(
                identifier: .gregorian
            )

        newYorkCalendar.timeZone =
            TimeZone(
                identifier: "America/New_York"
            )!

        let record =
            DonationRecord(
                date: makeDate(
                    year: 2026,
                    month: 3,
                    day: 1,
                    hour: 12,
                    calendar: newYorkCalendar
                ),
                location: "Test Location",
                donationType: "Whole blood",
                recordLabel: "Test record",
                recordReference: nil,
                nextPossibleDonationDate: makeDate(
                    year: 2026,
                    month: 3,
                    day: 9,
                    hour: 12,
                    calendar: newYorkCalendar
                )
            )

        let currentDate =
            makeDate(
                year: 2026,
                month: 3,
                day: 7,
                hour: 12,
                calendar: newYorkCalendar
            )

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate: currentDate,
                calendar: newYorkCalendar
            )

        #expect(
            result ==
                .notReady(
                    daysRemaining: 2
                )
        )
    }

    @Test
    func sriLankaSameThresholdDayReturnsReadyRegardlessOfTime() {

        var sriLankaCalendar =
            Calendar(
                identifier: .gregorian
            )

        sriLankaCalendar.timeZone =
            TimeZone(
                identifier: "Asia/Colombo"
            )!

        let record =
            DonationRecord(
                date: makeDate(
                    year: 2026,
                    month: 5,
                    day: 18,
                    hour: 18,
                    calendar: sriLankaCalendar
                ),
                location: "Matara Blood Bank",
                donationType: "Whole blood",
                recordLabel: "Blood-bank record",
                recordReference: "DB-2026-0518-006",
                nextPossibleDonationDate: makeDate(
                    year: 2026,
                    month: 9,
                    day: 18,
                    hour: 23,
                    calendar: sriLankaCalendar
                )
            )

        let currentDate =
            makeDate(
                year: 2026,
                month: 9,
                day: 18,
                hour: 1,
                calendar: sriLankaCalendar
            )

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate: currentDate,
                calendar: sriLankaCalendar
            )

        #expect(
            result == .ready
        )
    }

    private func prototypeRecord() -> DonationRecord {

        DonationRecord(
            date: makeDate(
                year: 2026,
                month: 5,
                day: 18
            ),
            location: "Matara Blood Bank",
            donationType: "Whole blood",
            recordLabel: "Blood-bank record",
            recordReference: "DB-2026-0518-006",
            nextPossibleDonationDate: makeDate(
                year: 2026,
                month: 9,
                day: 18
            )
        )
    }

    private func makeDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 12,
        calendar: Calendar? = nil
    ) -> Date {

        let selectedCalendar =
            calendar ?? self.calendar

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
