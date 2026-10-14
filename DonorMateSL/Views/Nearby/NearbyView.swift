//
//  NearbyView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/8/26.
//

import SwiftUI
import MapKit

struct NearbyView: View {

    private enum NearbyFilter {
        case all
        case camps
        case bloodBanks
    }

    @State private var selectedFilter: NearbyFilter = .all

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 5.9549,
                longitude: 80.5550
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.08,
                longitudeDelta: 0.08
            )
        )
    )

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                HStack(
                    alignment: .center,
                    spacing: 12
                ) {

                    Text("Nearby")
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundStyle(Color("TextPrimary"))

                    Spacer()

                    Button {
                        print("Nearby list tapped")
                    } label: {
                        Text("List")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color("TextPrimary"))
                            .padding(.horizontal, 12)
                            .frame(height: 32)
                            .background(Color("SurfacePrimary"))
                            .overlay {
                                Capsule()
                                    .stroke(
                                        Color("BorderPrimary"),
                                        lineWidth: 1
                                    )
                            }
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
                    .frame(height: 10)

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

                Spacer()
                    .frame(height: 10)

                Map(position: $cameraPosition)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                Color("NeutralBorderStrong"),
                                lineWidth: 1
                            )
                    }
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .background(Color("BackgroundPrimary"))
        }
    }

    private func filterButton(
        title: String,
        filter: NearbyFilter
    ) -> some View {

        let isSelected = selectedFilter == filter

        return Button {
            selectedFilter = filter
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
    NearbyView()
}
