//
//  SplashView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/4/26.
//

import SwiftUI

struct SplashView: View {
    var onContinue: () -> Void = {}

       var body: some View {
           VStack(spacing: 0) {

               Color("SurfacePrimary")
                   .frame(height: 0)
                   .ignoresSafeArea(edges: .top)

               ZStack {

                   LinearGradient(
                       colors: [
                           Color("SplashGradientStart"),
                           Color("DonorRedAccent")
                       ],
                       startPoint: .topTrailing,
                       endPoint: .bottomLeading
                   )

                   VStack(spacing: 0) {

                       Spacer()

                       ZStack {
                           RoundedRectangle(cornerRadius: 28)
                               .fill(Color("SurfacePrimary"))
                               .frame(width: 92, height: 92)
                               .shadow(
                                   color: .black.opacity(0.15),
                                   radius: 40,
                                   x: 0,
                                   y: 16
                               )

                           Image(systemName: "drop.fill")
                               .font(.system(size: 46, weight: .semibold))
                               .foregroundStyle(Color("DonorRedAccent"))
                       }

                       Spacer()
                           .frame(height: 22)

                       Text("DonorMate SL")
                           .font(.system(size: 28, weight: .heavy))
                           .foregroundStyle(.white)

                       Spacer()
                           .frame(height: 8)

                       Text("Know when. Know where. Donate again.")
                           .font(.system(size: 14))
                           .foregroundStyle(.white.opacity(0.78))

                       Spacer()
                   }

                   VStack {
                       Spacer()

                       Button {
                           onContinue()
                       } label: {
                           Text("Continue")
                               .font(.system(size: 15, weight: .bold))
                               .foregroundStyle(Color("TextPrimary"))
                               .padding(.horizontal, 14)
                               .frame(minWidth: 150, minHeight: 48)
                               .background(Color("SurfacePrimary"))
                               .clipShape(
                                   RoundedRectangle(cornerRadius: 14)
                               )
                       }
                       .buttonStyle(.plain)
                       .padding(.bottom, 34)
                   }
               }
           }
           .background(Color("SurfacePrimary"))
       }
   }

   #Preview {
       SplashView {
           print("Continue tapped")
       }
   }
