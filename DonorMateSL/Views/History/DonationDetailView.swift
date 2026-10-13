//
//  DonationDetailView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/13/26.
//

import SwiftUI

struct DonationDetailView: View {
    var body: some View {
           NavigationStack {
               ScrollView {
                   VStack(spacing: 0) {

                       HStack(
                           alignment: .center,
                           spacing: 10
                       ) {

                           Button {
                               print("Back tapped")
                           } label: {
                               Image(systemName: "chevron.left")
                                   .font(.system(size: 16, weight: .bold))
                                   .foregroundStyle(Color("TextPrimary"))
                                   .frame(width: 38, height: 38)
                                   .background(Color("SurfacePrimary"))
                                   .overlay {
                                       RoundedRectangle(cornerRadius: 12)
                                           .stroke(
                                               Color("BorderPrimary"),
                                               lineWidth: 1
                                           )
                                   }
                                   .clipShape(
                                       RoundedRectangle(cornerRadius: 12)
                                   )
                           }
                           .buttonStyle(.plain)
                           .accessibilityLabel("Back")

                           Text("Donation Details")
                               .font(.system(size: 15, weight: .bold))
                               .foregroundStyle(Color("TextPrimary"))

                           Spacer()

                           Text("Blood-bank record")
                               .font(.system(size: 12, weight: .bold))
                               .foregroundStyle(Color("SuccessGreen"))
                               .padding(.horizontal, 10)
                               .frame(height: 28)
                               .background(Color("SuccessGreenSoft"))
                               .overlay {
                                   Capsule()
                                       .stroke(
                                           Color("SuccessGreenBorder"),
                                           lineWidth: 1
                                       )
                               }
                               .clipShape(Capsule())
                       }
                       .frame(minHeight: 46)

                       Spacer()
                           .frame(height: 8)

                       HStack(
                           alignment: .top,
                           spacing: 12
                       ) {

                           VStack(
                               alignment: .leading,
                               spacing: 4
                           ) {

                               Text("Donation type")
                                   .font(.system(size: 12))
                                   .foregroundStyle(Color("TextSecondary"))

                               Text("Whole blood")
                                   .font(.system(size: 20, weight: .heavy))
                                   .foregroundStyle(Color("TextPrimary"))

                               Text("18 May 2026")
                                   .font(.system(size: 12))
                                   .foregroundStyle(Color("TextSecondary"))
                           }

                           Spacer()

                           ZStack {
                               RoundedRectangle(cornerRadius: 12)
                                   .fill(Color("DonorRedSoft"))
                                   .frame(width: 40, height: 40)

                               Image(systemName: "drop.fill")
                                   .font(.system(size: 17, weight: .semibold))
                                   .foregroundStyle(Color("DonorRed"))
                           }
                           .accessibilityHidden(true)
                       }
                       .padding(14)
                       .frame(
                           maxWidth: .infinity,
                           alignment: .leading
                       )
                       .background(Color("SurfacePrimary"))
                       .overlay {
                           RoundedRectangle(cornerRadius: 16)
                               .stroke(
                                   Color("BorderPrimary"),
                                   lineWidth: 1
                               )
                       }
                       .clipShape(
                           RoundedRectangle(cornerRadius: 16)
                       )

                       Spacer()
                           .frame(height: 12)

                       DetailInfoRow(
                           systemImage: "location.fill",
                           label: "Location",
                           value: "Matara Blood Bank"
                       )

                       Spacer()
                           .frame(height: 10)

                       DetailInfoRow(
                           systemImage: "building.2.fill",
                           label: "Recorded by",
                           value: "Blood-bank staff"
                       )

                       Spacer()
                           .frame(height: 10)

                       DetailInfoRow(
                           systemImage: "number",
                           label: "Record reference",
                           value: "DB-2026-0518-006"
                       )

                       Spacer()
                           .frame(height: 14)

                       VStack(
                           alignment: .leading,
                           spacing: 4
                       ) {

                           Text("Next possible donation date")
                               .font(.system(size: 12))
                               .foregroundStyle(Color("TextSecondary"))

                           Text("18 September 2026")
                               .font(.system(size: 20, weight: .heavy))
                               .foregroundStyle(Color("TextPrimary"))
                       }
                       .padding(14)
                       .frame(
                           maxWidth: .infinity,
                           alignment: .leading
                       )
                       .background(Color("SuccessGreenSoft"))
                       .overlay {
                           RoundedRectangle(cornerRadius: 16)
                               .stroke(
                                   Color("SuccessGreenBorder"),
                                   lineWidth: 1
                               )
                       }
                       .clipShape(
                           RoundedRectangle(cornerRadius: 16)
                       )

                       Spacer()
                           .frame(height: 14)

                       NeutralMessageCard(
                           systemImage: "lock.fill",
                           title: "View-only record",
                           detail: "This donation cannot be changed in DonorMate.",
                           style: .standard
                       )

                       Spacer()
                           .frame(height: 28)
                   }
                   .padding(.horizontal, 18)
                   .padding(.top, 18)
               }
               .background(Color("BackgroundPrimary"))
           }
       }
   }

   #Preview {
       DonationDetailView()
   }
