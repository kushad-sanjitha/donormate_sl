//
//  CountdownOnboardingVisual.swift
//  DonorMateSL
//
//  Created by user300742 on 10/4/26.
//

import SwiftUI

struct CountdownOnboardingVisual: View {
    var body: some View {
           VStack(
               alignment: .leading,
               spacing: 0
           ) {

               HStack(
                   alignment: .top,
                   spacing: 16
               ) {

                   VStack(
                       alignment: .leading,
                       spacing: 0
                   ) {

                       Text("Next possible donation")
                           .font(.system(size: 12))
                           .foregroundStyle(Color("TextSecondary"))

                       Text("18 Sep")
                           .font(.system(size: 34, weight: .heavy))
                           .foregroundStyle(Color("TextPrimary"))
                           .padding(.top, 4)

                       Text("Until your next tracked donation date")
                           .font(.system(size: 12))
                           .foregroundStyle(Color("TextSecondary"))
                           .padding(.top, 5)
                   }

                   Spacer()

                   ZStack {

                       RoundedRectangle(cornerRadius: 14)
                           .fill(Color("DonorRedSoft"))
                           .frame(
                               width: 44,
                               height: 44
                           )

                       Image(systemName: "hourglass")
                           .font(
                               .system(
                                   size: 20,
                                   weight: .semibold
                               )
                           )
                           .foregroundStyle(Color("DonorRed"))
                   }
                   .accessibilityHidden(true)
               }

               Spacer()
                   .frame(height: 18)

               GeometryReader { geometry in
                   ZStack(alignment: .leading) {

                       Capsule()
                           .fill(Color("NeutralSoft"))

                       Capsule()
                           .fill(Color("DonorRed"))
                           .frame(
                               width: geometry.size.width * 0.72
                           )
                   }
               }
               .frame(height: 8)
               .accessibilityElement()
               .accessibilityLabel("Donation interval progress")
               .accessibilityValue("72 percent")

               Text("24 days remaining")
                   .font(.system(size: 12))
                   .foregroundStyle(Color("TextSecondary"))
                   .padding(.top, 8)
           }
           .padding(18)
           .frame(maxWidth: .infinity)
           .background(Color("SurfacePrimary"))
           .overlay {
               RoundedRectangle(cornerRadius: 20)
                   .stroke(
                       Color("BorderPrimary"),
                       lineWidth: 1
                   )
           }
           .clipShape(
               RoundedRectangle(cornerRadius: 20)
           )
           .shadow(
               color: .black.opacity(0.06),
               radius: 10,
               x: 0,
               y: 4
           )
       }
   }

   #Preview {
       CountdownOnboardingVisual()
           .padding()
   }
