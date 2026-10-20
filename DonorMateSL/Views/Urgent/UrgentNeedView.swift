//
//  UrgentNeedView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/20/26.
//

import SwiftUI

struct UrgentNeedView: View {

    let urgentNeed: UrgentBloodNeed
    let location: DonationLocation
    let readiness: DonationReadinessState
    let distanceText: String

    let onDirections: () -> Void
    let onSave: () -> Void
    let onRemind: () -> Void

    var body: some View {

        Text("Urgent Need")
    }
}

#Preview {

    UrgentNeedView(
        urgentNeed: UrgentBloodNeed(
            id: "matara-a-positive-urgent",
            bloodGroup: "A+",
            locationID: "matara-blood-bank",
            alertStatus: "Active today",
            sourceText: "Prototype data unless an authorised official source is connected."
        ),
        location: DonationLocation(
            id: "matara-blood-bank",
            name: "Matara Blood Bank",
            type: .bloodBank,
            latitude: 5.9497,
            longitude: 80.5428,
            detail: "Open today"
        ),
        readiness: .ready,
        distanceText: "2.8 km",
        onDirections: {
            print("Directions tapped")
        },
        onSave: {
            print("Save tapped")
        },
        onRemind: {
            print("Reminder tapped")
        }
    )
}
