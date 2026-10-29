//
//  NearbyFilterControl.swift
//  DonorMateSL
//
//  Created by user300742 on 10/15/26.
//

import SwiftUI

struct NearbyFilterControl: View {

    let selectedFilter: NearbyFilter
    let onFilterChanged: (NearbyFilter) -> Void

    var body: some View {
        HStack(spacing: 3) {

            filterButton(
                title: "All",
                filter: .all
            )

            filterButton(
                title: "Camps",
                filter: .camps
            )

            filterButton(
                title: "Blood Banks",
                filter: .bloodBanks
            )
        }
        .padding(3)
        .background(Color("NeutralSoft"))
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
    }

    private func filterButton(
        title: String,
        filter: NearbyFilter
    ) -> some View {

        let isSelected = selectedFilter == filter

        return Button {
            onFilterChanged(filter)
        } label: {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(
                    isSelected
                        ? Color("TextPrimary")
                        : Color("TextSecondary")
                )
                .frame(
                    maxWidth: .infinity,
                    minHeight: 34
                )
                .background(
                    isSelected
                        ? Color("SurfacePrimary")
                        : Color.clear
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 9)
                )
                .shadow(
                    color: isSelected
                        ? Color.black.opacity(0.06)
                        : Color.clear,
                    radius: 2,
                    x: 0,
                    y: 1
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NearbyFilterControl(
        selectedFilter: .all,
        onFilterChanged: { filter in
            print("Filter:", filter)
        }
    )
    .padding(18)
    .background(Color("BackgroundPrimary"))
}
