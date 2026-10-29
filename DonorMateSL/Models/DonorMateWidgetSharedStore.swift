//
//  DonorMateWidgetSharedStore.swift
//  DonorMateSL
//
//  Created by user300742 on 10/26/26.
//

import Foundation

nonisolated struct DonorMateWidgetSharedStore {
    static let appGroupIdentifier = "group.iosdev.DonorMateSL"

    private static let snapshotKey = "donormate.widget.status.snapshot.v1"

    private let defaults: UserDefaults

    init?(suiteName: String = Self.appGroupIdentifier) {
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            return nil
        }
        self.defaults = defaults
    }

    func load() -> DonorMateWidgetSnapshot? {
        guard let data = defaults.data(forKey: Self.snapshotKey) else {
            return nil
        }
        return try? JSONDecoder().decode(DonorMateWidgetSnapshot.self, from: data)
    }

    @discardableResult
    func save(_ snapshot: DonorMateWidgetSnapshot) -> Bool {
        guard let encoded = try? JSONEncoder().encode(snapshot) else {
            return false
        }
        defaults.set(encoded, forKey: Self.snapshotKey)
        return defaults.data(forKey: Self.snapshotKey) == encoded
    }

    func clear() {
        defaults.removeObject(forKey: Self.snapshotKey)
    }
}
