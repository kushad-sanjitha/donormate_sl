//
//  SavedItemsStoreTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/24/26.
//

import Foundation
import Testing
@testable import DonorMateSL

@MainActor
struct SavedItemsStoreTests {

    private func testRepository() -> (LocalSavedLocationsRepository, UserDefaults, String) {
        let name = "DonorMate.SavedItemsTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        return (LocalSavedLocationsRepository(defaults: defaults), defaults, name)
    }

    @Test
    func signedOutCannotSave() async {
        let store = SavedItemsStore(repository: LocalSavedLocationsRepository())
        #expect(store.savedLocationIDs.isEmpty)
        #expect(await store.save(locationID: "matara-donation-camp") == false)
    }

    @Test
    func savesAndRemovesALocation() async {
        let (repository, defaults, name) = testRepository()
        defer { defaults.removePersistentDomain(forName: name) }
        let store = SavedItemsStore(repository: repository)
        await store.activate(for: "user-a")

        #expect(await store.save(locationID: "matara-donation-camp"))
        #expect(store.isSaved("matara-donation-camp"))
        #expect(await store.remove(locationID: "matara-donation-camp"))
        #expect(store.savedLocationIDs.isEmpty)
    }

    @Test
    func repeatedSaveIsIdempotent() async {
        let (repository, defaults, name) = testRepository()
        defer { defaults.removePersistentDomain(forName: name) }
        let store = SavedItemsStore(repository: repository)
        await store.activate(for: "user-a")

        #expect(await store.save(locationID: "matara-donation-camp"))
        #expect(await store.save(locationID: "matara-donation-camp"))
        #expect(store.savedLocationIDs.count == 1)
    }

    @Test
    func survivesStoreRecreation() async {
        let (repository, defaults, name) = testRepository()
        defer { defaults.removePersistentDomain(forName: name) }
        let first = SavedItemsStore(repository: repository)
        await first.activate(for: "user-a")
        #expect(await first.save(locationID: "matara-donation-camp"))

        let second = SavedItemsStore(repository: repository)
        await second.activate(for: "user-a")
        #expect(second.isSaved("matara-donation-camp"))
    }

    @Test
    func savedItemsAreIsolatedByAccount() async {
        let (repository, defaults, name) = testRepository()
        defer { defaults.removePersistentDomain(forName: name) }
        let store = SavedItemsStore(repository: repository)
        await store.activate(for: "user-a")
        #expect(await store.save(locationID: "matara-donation-camp"))

        await store.activate(for: "user-b")
        #expect(store.savedLocationIDs.isEmpty)
        #expect(await store.save(locationID: "matara-blood-bank"))

        await store.activate(for: nil)
        #expect(store.savedLocationIDs.isEmpty)
        await store.activate(for: "user-a")
        #expect(store.isSaved("matara-donation-camp"))
        #expect(!store.isSaved("matara-blood-bank"))
    }

    @Test
    func blankLocationIDsCannotBeSaved() async {
        let (repository, defaults, name) = testRepository()
        defer { defaults.removePersistentDomain(forName: name) }
        let store = SavedItemsStore(repository: repository)
        await store.activate(for: "user-a")
        #expect(await store.save(locationID: "   ") == false)
        #expect(store.savedLocationIDs.isEmpty)
    }

    @Test
    func failedWriteRestoresPreviousState() async {
        let store = SavedItemsStore(repository: FailingSavedLocationsRepository())
        await store.activate(for: "user-a")
        #expect(await store.save(locationID: "matara-donation-camp") == false)
        #expect(store.savedLocationIDs.isEmpty)
        #expect(store.errorMessage != nil)
    }
}

@MainActor
private struct FailingSavedLocationsRepository: SavedLocationsRepository {
    struct WriteError: Error {}

    func loadLocationIDs(for userID: String) async throws -> Set<String> {
        []
    }

    func saveLocationIDs(_ ids: Set<String>, for userID: String) async throws {
        throw WriteError()
    }
}

