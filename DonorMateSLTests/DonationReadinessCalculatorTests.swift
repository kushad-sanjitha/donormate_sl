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
    func noRecordReturnsUnknown() {

        let result =
            DonationReadinessCalculator.readiness(
                for: nil,
                currentDate:
                    makeDate(
                        year: 2026,
                        month: 10,
                        day: 20
                    ),
                calendar: calendar
            )

        #expect(result == .unknown)
    }

    @Test
    func missingRecordedNextDateUsesFourMonthMinimum() {

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

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate:
                    makeDate(
                        year: 2026,
                        month: 9,
                        day: 1
                    ),
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
    func thresholdDateFromFourMonthMinimumReturnsReady() {

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

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate:
                    makeDate(
                        year: 2026,
                        month: 9,
                        day: 18
                    ),
                calendar: calendar
            )

        #expect(result == .ready)
    }

    @Test
    func earlierRecordedDateCannotShortenFourMonthMinimum() {

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
                        month: 6,
                        day: 18
                    )
            )

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate:
                    makeDate(
                        year: 2026,
                        month: 9,
                        day: 1
                    ),
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
    func laterRecordedDeferralIsRespected() {

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

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate:
                    makeDate(
                        year: 2026,
                        month: 9,
                        day: 18
                    ),
                calendar: calendar
            )

        #expect(
            result ==
                .notReady(
                    daysRemaining: 30
                )
        )
    }

    @Test
    func recordedDateEqualToMinimumUsesMinimum() {

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

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate:
                    makeDate(
                        year: 2026,
                        month: 9,
                        day: 18
                    ),
                calendar: calendar
            )

        #expect(result == .ready)
    }

    @Test
    func invalidEarlierRecordedDateFallsBackToMinimum() {

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
                        month: 5,
                        day: 17
                    )
            )

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate:
                    makeDate(
                        year: 2026,
                        month: 9,
                        day: 18
                    ),
                calendar: calendar
            )

        #expect(result == .ready)
    }

    @Test
    func futureDonationDateReturnsUnknown() {

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

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate:
                    makeDate(
                        year: 2026,
                        month: 10,
                        day: 20
                    ),
                calendar: calendar
            )

        #expect(result == .unknown)
    }

    @Test
    func unsupportedDonationTypeReturnsUnknown() {

        let record =
            DonationRecord(
                date:
                    makeDate(
                        year: 2026,
                        month: 5,
                        day: 18
                    ),
                location: "Matara Blood Bank",
                donationType: "Platelets",
                recordLabel: "Blood-bank record",
                recordReference: nil,
                nextPossibleDonationDate: nil
            )

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate:
                    makeDate(
                        year: 2026,
                        month: 10,
                        day: 20
                    ),
                calendar: calendar
            )

        #expect(result == .unknown)
    }

    @Test
    func differentHoursOnThresholdDateStillReturnsReady() {

        let record =
            makeRecord(
                donationDate:
                    makeDate(
                        year: 2026,
                        month: 5,
                        day: 18,
                        hour: 18
                    ),
                nextPossibleDate: nil
            )

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate:
                    makeDate(
                        year: 2026,
                        month: 9,
                        day: 18,
                        hour: 1
                    ),
                calendar: calendar
            )

        #expect(result == .ready)
    }

    @Test
    func sriLankaCalendarUsesLocalCalendarDays() {

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
                date:
                    makeDate(
                        year: 2026,
                        month: 5,
                        day: 18,
                        hour: 23,
                        calendar:
                            sriLankaCalendar
                    ),
                location: "Matara Blood Bank",
                donationType: "Whole blood",
                recordLabel: "Blood-bank record",
                recordReference: nil,
                nextPossibleDonationDate: nil
            )

        let result =
            DonationReadinessCalculator.readiness(
                for: record,
                currentDate:
                    makeDate(
                        year: 2026,
                        month: 9,
                        day: 17,
                        hour: 1,
                        calendar:
                            sriLankaCalendar
                    ),
                calendar: sriLankaCalendar
            )

        #expect(
            result ==
                .notReady(
                    daysRemaining: 1
                )
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
