//
//  UrgentBloodNeedStore.swift
//  DonorMateSL
//
//  Created by user300742 on 10/24/26.
//

import Foundation
import Combine

@MainActor
final class UrgentBloodNeedStore: ObservableObject {

    @Published private(set) var needs: [UrgentBloodNeed]

    init(needs: [UrgentBloodNeed] = UrgentBloodNeedCatalog.urgentNeeds) {
        self.needs = Self.validUniqueNeeds(needs)
    }

    func need(for id: String) -> UrgentBloodNeed? {
        needs.first { $0.id == id }
    }

    func activeNeeds(at date: Date) -> [UrgentBloodNeed] {
        needs
            .filter { $0.isActive(at: date) }
            .sorted {
                if $0.expiresAt == $1.expiresAt {
                    return $0.id < $1.id
                }
                return $0.expiresAt < $1.expiresAt
            }
    }

    func replaceNeeds(with needs: [UrgentBloodNeed]) {
        self.needs = Self.validUniqueNeeds(needs)
    }

    private static func validUniqueNeeds(
        _ needs: [UrgentBloodNeed]
    ) -> [UrgentBloodNeed] {
        var ids = Set<String>()

        return needs.filter { need in
            let id = need.id.trimmingCharacters(in: .whitespacesAndNewlines)
            let group = need.bloodGroup.trimmingCharacters(in: .whitespacesAndNewlines)
            let locationID = need.locationID.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !id.isEmpty, !group.isEmpty, !locationID.isEmpty,
                  need.publishedAt < need.expiresAt else {
                return false
            }

            return ids.insert(id).inserted
        }
    }
}
