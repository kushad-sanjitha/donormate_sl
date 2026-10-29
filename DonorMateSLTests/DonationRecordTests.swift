//
//  DonationRecordTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/20/26.
//

import Foundation
import Testing
@testable import DonorMateSL

struct DonationRecordTests {

    @Test
    func locationAndTypeCombinesBothValues() {

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
                    month: 9,
                    day: 18
                )
            )

        #expect(
            record.locationAndType ==
                "Matara Blood Bank · Whole blood"
        )
    }

    @Test
    func locationAndTypeUsesRecordValues() {

        let record =
            DonationRecord(
                date: makeDate(
                    year: 2026,
                    month: 6,
                    day: 12
                ),
                location: "Walgama Donation Camp",
                donationType: "Platelets",
                recordLabel: "Blood-bank record",
                recordReference: "DB-2026-0612-002",
                nextPossibleDonationDate: makeDate(
                    year: 2026,
                    month: 10,
                    day: 12
                )
            )

        #expect(
            record.locationAndType ==
                "Walgama Donation Camp · Platelets"
        )
    }

    @Test
    func locationAndTypePreservesUnicode() {

        let record =
            DonationRecord(
                date: makeDate(
                    year: 2026,
                    month: 7,
                    day: 8
                ),
                location: "මාතර රුධිර බැංකුව",
                donationType: "Whole blood",
                recordLabel: "Blood-bank record",
                recordReference: "DB-2026-0708-003",
                nextPossibleDonationDate: makeDate(
                    year: 2026,
                    month: 11,
                    day: 8
                )
            )

        #expect(
            record.locationAndType ==
                "මාතර රුධිර බැංකුව · Whole blood"
        )
    }

    @Test
    func locationAndTypeWorksWithNilOptionalFields() {

        let record =
            DonationRecord(
                date: makeDate(
                    year: 2026,
                    month: 8,
                    day: 2
                ),
                location: "Matara Blood Bank",
                donationType: "Whole blood",
                recordLabel: "Blood-bank record",
                recordReference: nil,
                nextPossibleDonationDate: nil
            )

        #expect(
            record.locationAndType ==
                "Matara Blood Bank · Whole blood"
        )
    }

    private func makeDate(
        year: Int,
        month: Int,
        day: Int
    ) -> Date {

        var calendar =
            Calendar(
                identifier: .gregorian
            )

        calendar.timeZone =
            TimeZone(
                secondsFromGMT: 0
            )!

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
