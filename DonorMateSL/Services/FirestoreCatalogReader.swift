//
//  FirestoreCatalogReader.swift
//  DonorMateSL
//
//  Created by user300742 on 10/29/26.
//

import FirebaseFirestore
import Foundation

struct FirestoreCatalogSnapshot {
    let locations: [DonationLocation]
    let urgentNeeds: [UrgentBloodNeed]
}

@MainActor
enum FirestoreCatalogReader {
    static func load() async throws -> FirestoreCatalogSnapshot {
        let firestore = Firestore.firestore()
        let locationDocuments = try await firestore.collection("donationLocations")
            .getDocuments(source: .server)
        let needDocuments = try await firestore.collection("urgentBloodNeeds")
            .getDocuments(source: .server)

        return FirestoreCatalogSnapshot(
            locations: locationDocuments.documents.compactMap(decodeLocation),
            urgentNeeds: needDocuments.documents.compactMap(decodeUrgentNeed)
        )
    }

    private static func decodeLocation(_ document: QueryDocumentSnapshot) -> DonationLocation? {
        decodeLocation(fields: document.data(), id: document.documentID)
    }

    static func decodeLocation(fields: [String: Any], id: String) -> DonationLocation? {
        guard let name = fields["name"] as? String,
              let typeText = fields["type"] as? String,
              let latitude = fields["latitude"] as? Double,
              let longitude = fields["longitude"] as? Double,
              let detail = fields["detail"] as? String,
              !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              latitude.isFinite, longitude.isFinite,
              (-90...90).contains(latitude),
              (-180...180).contains(longitude) else { return nil }

        let type: DonationLocation.LocationType
        switch typeText {
        case "camp": type = .camp
        case "bloodBank": type = .bloodBank
        default: return nil
        }

        return DonationLocation(
            id: id,
            name: name,
            type: type,
            latitude: latitude,
            longitude: longitude,
            detail: detail,
            venue: fields["venue"] as? String,
            organiser: fields["organiser"] as? String,
            openingHours: fields["openingHours"] as? String,
            contact: fields["contact"] as? String
        )
    }

    private static func decodeUrgentNeed(_ document: QueryDocumentSnapshot) -> UrgentBloodNeed? {
        decodeUrgentNeed(fields: document.data(), id: document.documentID)
    }

    static func decodeUrgentNeed(fields: [String: Any], id: String) -> UrgentBloodNeed? {
        guard let bloodGroup = fields["bloodGroup"] as? String,
              let locationID = fields["locationID"] as? String,
              let statusText = fields["status"] as? String,
              let status = UrgentBloodNeedStatus(rawValue: statusText),
              let published = dateValue(fields["publishedAt"]),
              let expires = dateValue(fields["expiresAt"]),
              let sourceText = fields["sourceText"] as? String,
              !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !bloodGroup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !locationID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              published < expires else { return nil }

        return UrgentBloodNeed(
            id: id,
            bloodGroup: bloodGroup,
            locationID: locationID,
            status: status,
            publishedAt: published,
            expiresAt: expires,
            sourceText: sourceText,
            isDemonstration: fields["isDemonstration"] as? Bool ?? true
        )
    }

    private static func dateValue(_ value: Any?) -> Date? {
        if let timestamp = value as? Timestamp { return timestamp.dateValue() }
        return value as? Date
    }
}
