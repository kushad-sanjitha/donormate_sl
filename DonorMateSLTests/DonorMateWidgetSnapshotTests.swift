//
//  DonorMateWidgetSnapshotTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/26/26.
//

import Foundation
import Testing
@testable import DonorMateSL

struct DonorMateWidgetSnapshotTests {
    private var calendar: Calendar {
        var result = Calendar(identifier: .gregorian)
        result.timeZone = TimeZone(secondsFromGMT: 0)!
        return result
    }

    private func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func snapshot(
        now: Date,
        nextDate: Date,
        isVerified: Bool = true,
        publishedAt: Date? = nil,
        ownerID: String = "account-a"
    ) -> DonorMateWidgetSnapshot {
        DonorMateWidgetSnapshot(
            ownerID: ownerID,
            lastDonationDate: day(2026, 6, 26),
            nextPossibleDonationDate: nextDate,
            publishedAt: publishedAt ?? now,
            isVerified: isVerified
        )
    }

    @Test("Verified status becomes a countdown")
    func validCountdown() {
        let now = day(2026, 10, 26)
        let value = snapshot(now: now, nextDate: day(2026, 11, 7))
        #expect(DonorMateWidgetReadinessResolver.resolve(value, now: now, calendar: calendar)
                == .countdown(daysRemaining: 12, nextPossibleDate: day(2026, 11, 7)))
    }

    @Test("Threshold day is ready")
    func thresholdIsReady() {
        let now = day(2026, 10, 26)
        let value = snapshot(now: now, nextDate: now)
        #expect(DonorMateWidgetReadinessResolver.resolve(value, now: now, calendar: calendar)
                == .ready)
    }

    @Test("A day after the threshold remains ready")
    func afterThresholdIsReady() {
        let now = day(2026, 10, 27)
        let value = snapshot(now: now, nextDate: day(2026, 10, 26))
        #expect(DonorMateWidgetReadinessResolver.resolve(value, now: now, calendar: calendar)
                == .ready)
    }

    @Test("Unverified records never reach the widget")
    func rejectsUnverified() {
        let now = day(2026, 10, 26)
        let value = snapshot(now: now, nextDate: day(2026, 11, 7), isVerified: false)
        #expect(DonorMateWidgetReadinessResolver.resolve(value, now: now, calendar: calendar)
                == .unavailable)
    }

    @Test("Missing and anonymous snapshots are unavailable")
    func rejectsMissingOrAnonymous() {
        let now = day(2026, 10, 26)
        #expect(DonorMateWidgetReadinessResolver.resolve(nil, now: now, calendar: calendar)
                == .unavailable)
        let value = snapshot(now: now, nextDate: day(2026, 11, 7), ownerID: "")
        #expect(DonorMateWidgetReadinessResolver.resolve(value, now: now, calendar: calendar)
                == .unavailable)
    }

    @Test("Future donation date is unavailable")
    func rejectsFutureDonation() {
        let now = day(2026, 6, 25)
        let value = snapshot(now: now, nextDate: day(2026, 11, 7))
        #expect(DonorMateWidgetReadinessResolver.resolve(value, now: now, calendar: calendar)
                == .unavailable)
    }

    @Test("Next date cannot precede the donation date")
    func rejectsInvalidDateOrder() {
        let now = day(2026, 10, 26)
        let value = snapshot(now: now, nextDate: day(2026, 6, 25))
        #expect(DonorMateWidgetReadinessResolver.resolve(value, now: now, calendar: calendar)
                == .unavailable)
    }

    @Test("Snapshots older than seven days become unavailable")
    func expiresOldSnapshot() {
        let now = day(2026, 10, 26)
        let value = snapshot(
            now: now,
            nextDate: day(2026, 11, 7),
            publishedAt: day(2026, 10, 18)
        )
        #expect(DonorMateWidgetReadinessResolver.resolve(value, now: now, calendar: calendar)
                == .unavailable)
    }

    @Test("Future publication timestamps are rejected")
    func rejectsFutureSnapshot() {
        let now = day(2026, 10, 26)
        let value = snapshot(now: now, nextDate: day(2026, 11, 7),
                             publishedAt: day(2026, 10, 27))
        #expect(DonorMateWidgetReadinessResolver.resolve(value, now: now, calendar: calendar)
                == .unavailable)
    }

    @Test("Snapshot persists and is removed after clear")
    func saveLoadAndClear() throws {
        let testSuite = "donormate.widget.tests.\(UUID().uuidString)"
        defer { UserDefaults(suiteName: testSuite)?.removePersistentDomain(forName: testSuite) }
        let repository = try #require(DonorMateWidgetSharedStore(suiteName: testSuite))
        let now = day(2026, 10, 26)
        let value = snapshot(now: now, nextDate: day(2026, 11, 7))

        #expect(repository.load() == nil)
        #expect(repository.save(value))
        #expect(repository.load() == value)
        repository.clear()
        #expect(repository.load() == nil)
    }
}
