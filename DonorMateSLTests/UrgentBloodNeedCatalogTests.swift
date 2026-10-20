//
//  UrgentBloodNeedCatalogTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/20/26.
//

import Foundation
import Testing
@testable import DonorMateSL

struct UrgentBloodNeedCatalogTests {

    @Test
    func catalogContainsOneUrgentNeed() {

        #expect(
            UrgentBloodNeedCatalog.urgentNeeds.count == 1
        )
    }

    @Test
    func urgentNeedIdentifiersAreUnique() {

        let identifiers =
            UrgentBloodNeedCatalog.urgentNeeds.map(
                \.id
            )

        #expect(
            Set(identifiers).count ==
                identifiers.count
        )
    }

    @Test
    func knownUrgentNeedLookupReturnsExpectedRequest() throws {

        let urgentNeed =
            try #require(
                UrgentBloodNeedCatalog.urgentNeed(
                    for: "matara-a-positive-urgent"
                )
            )

        #expect(
            urgentNeed.id ==
                "matara-a-positive-urgent"
        )

        #expect(
            urgentNeed.bloodGroup ==
                "A+"
        )

        #expect(
            urgentNeed.locationID ==
                "matara-blood-bank"
        )

        #expect(
            urgentNeed.alertStatus ==
                "Active today"
        )

        #expect(
            urgentNeed.sourceText ==
                "Prototype data unless an authorised official source is connected."
        )
    }

    @Test
    func unknownUrgentNeedIdentifierReturnsNil() {

        let urgentNeed =
            UrgentBloodNeedCatalog.urgentNeed(
                for: "unknown-urgent-need"
            )

        #expect(
            urgentNeed == nil
        )
    }

    @Test
    func emptyUrgentNeedIdentifierReturnsNil() {

        let urgentNeed =
            UrgentBloodNeedCatalog.urgentNeed(
                for: ""
            )

        #expect(
            urgentNeed == nil
        )
    }

    @Test
    func everyCatalogUrgentNeedCanBeLookedUp() throws {

        for expectedUrgentNeed in
            UrgentBloodNeedCatalog.urgentNeeds {

            let resolvedUrgentNeed =
                try #require(
                    UrgentBloodNeedCatalog.urgentNeed(
                        for: expectedUrgentNeed.id
                    )
                )

            #expect(
                resolvedUrgentNeed.id ==
                    expectedUrgentNeed.id
            )

            #expect(
                resolvedUrgentNeed.bloodGroup ==
                    expectedUrgentNeed.bloodGroup
            )

            #expect(
                resolvedUrgentNeed.locationID ==
                    expectedUrgentNeed.locationID
            )

            #expect(
                resolvedUrgentNeed.alertStatus ==
                    expectedUrgentNeed.alertStatus
            )

            #expect(
                resolvedUrgentNeed.sourceText ==
                    expectedUrgentNeed.sourceText
            )
        }
    }

    @Test
    func allUrgentNeedsHaveRequiredInformation() {

        for urgentNeed in
            UrgentBloodNeedCatalog.urgentNeeds {

            #expect(
                !urgentNeed.id
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .isEmpty
            )

            #expect(
                !urgentNeed.bloodGroup
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .isEmpty
            )

            #expect(
                !urgentNeed.locationID
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .isEmpty
            )

            #expect(
                !urgentNeed.alertStatus
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .isEmpty
            )

            #expect(
                !urgentNeed.sourceText
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .isEmpty
            )
        }
    }

    @Test
    func everyUrgentNeedReferencesExistingDonationLocation() {

        for urgentNeed in
            UrgentBloodNeedCatalog.urgentNeeds {

            let location =
                DonationLocationCatalog.location(
                    for: urgentNeed.locationID
                )

            #expect(
                location != nil
            )
        }
    }

    @Test
    func aPositiveUrgentNeedReferencesMataraBloodBank() throws {

        let urgentNeed =
            try #require(
                UrgentBloodNeedCatalog.urgentNeed(
                    for: "matara-a-positive-urgent"
                )
            )

        let location =
            try #require(
                DonationLocationCatalog.location(
                    for: urgentNeed.locationID
                )
            )

        #expect(
            urgentNeed.bloodGroup ==
                "A+"
        )

        #expect(
            location.id ==
                "matara-blood-bank"
        )

        #expect(
            location.name ==
                "Matara Blood Bank"
        )

        #expect(
            location.type ==
                .bloodBank
        )
    }

    @Test
    func prototypeSourceDisclosureIsPresent() throws {

        let urgentNeed =
            try #require(
                UrgentBloodNeedCatalog.urgentNeed(
                    for: "matara-a-positive-urgent"
                )
            )

        #expect(
            urgentNeed.sourceText ==
                "Prototype data unless an authorised official source is connected."
        )
    }
}
