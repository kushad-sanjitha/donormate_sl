//
//  SavedItemsStore.swift
//  DonorMateSL
//
//  Created by user300742 on 10/24/26.
//

import Foundation
import Combine

@MainActor
protocol SavedLocationsRepository {
    func loadLocationIDs(for userID: String) async throws -> Set<String>
    func saveLocationIDs(_ ids: Set<String>, for userID: String) async throws
}

@MainActor
struct LocalSavedLocationsRepository: SavedLocationsRepository {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadLocationIDs(for userID: String) async throws -> Set<String> {
        Set(defaults.stringArray(forKey: key(for: userID)) ?? [])
    }

    func saveLocationIDs(_ ids: Set<String>, for userID: String) async throws {
        defaults.set(ids.sorted(), forKey: key(for: userID))
    }

    private func key(for userID: String) -> String {
        "DonorMate.savedLocations.\(userID)"
    }
}

@MainActor
final class SavedItemsStore: ObservableObject {
    @Published private(set) var savedLocationIDs: Set<String> = []
    @Published private(set) var activeUserID: String?
    @Published private(set) var isLoading = false
    @Published private(set) var isSaving = false
    @Published private(set) var errorMessage: String?

    private let repository: any SavedLocationsRepository
    private var accountGeneration = 0

    init(repository: (any SavedLocationsRepository)? = nil) {
        self.repository = repository ?? LocalSavedLocationsRepository()
    }

    func activate(for userID: String?) async {
        let cleanID = userID?.trimmingCharacters(in: .whitespacesAndNewlines)
        let nextID = cleanID?.isEmpty == false ? cleanID : nil
        guard activeUserID != nextID || errorMessage != nil else { return }

        accountGeneration += 1
        let generation = accountGeneration
        activeUserID = nextID
        savedLocationIDs = []
        errorMessage = nil
        isLoading = nextID != nil
        isSaving = false

        guard let nextID else { return }

        do {
            let ids = try await repository.loadLocationIDs(for: nextID)
            guard generation == accountGeneration, activeUserID == nextID else { return }
            savedLocationIDs = Set(ids.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
        } catch {
            guard generation == accountGeneration, activeUserID == nextID else { return }
            errorMessage = "Saved locations could not be loaded. Try again."
        }

        guard generation == accountGeneration else { return }
        isLoading = false
    }

    func isSaved(_ locationID: String) -> Bool {
        savedLocationIDs.contains(locationID)
    }

    @discardableResult
    func save(locationID: String) async -> Bool {
        await update(locationID: locationID, shouldSave: true)
    }

    @discardableResult
    func remove(locationID: String) async -> Bool {
        await update(locationID: locationID, shouldSave: false)
    }

    @discardableResult
    func toggle(locationID: String) async -> Bool {
        await update(locationID: locationID, shouldSave: !isSaved(locationID))
    }

    private func update(locationID: String, shouldSave: Bool) async -> Bool {
        let cleanID = locationID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let userID = activeUserID, !cleanID.isEmpty,
              !isLoading, !isSaving else { return false }

        let original = savedLocationIDs
        if shouldSave {
            savedLocationIDs.insert(cleanID)
        } else {
            savedLocationIDs.remove(cleanID)
        }
        guard savedLocationIDs != original else { return true }

        isSaving = true
        errorMessage = nil
        let generation = accountGeneration
        let updated = savedLocationIDs

        do {
            try await repository.saveLocationIDs(updated, for: userID)
            guard generation == accountGeneration, activeUserID == userID else { return false }
            isSaving = false
            return true
        } catch {
            guard generation == accountGeneration, activeUserID == userID else { return false }
            savedLocationIDs = original
            isSaving = false
            errorMessage = "Could not update saved locations. Please try again."
            return false
        }
    }
}
