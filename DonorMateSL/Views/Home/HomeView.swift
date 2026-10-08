//
//  HomeView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/8/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
           NavigationStack {
               VStack(
                   alignment: .leading,
                   spacing: 10
               ) {

                   Text("Home")
                       .font(.system(size: 28, weight: .heavy))
                       .foregroundStyle(Color("TextPrimary"))

                   Text("Donor dashboard")
                       .font(.system(size: 14))
                       .foregroundStyle(Color("TextSecondary"))

                   Spacer()
               }
               .padding(.horizontal, 18)
               .padding(.top, 18)
               .frame(
                   maxWidth: .infinity,
                   maxHeight: .infinity,
                   alignment: .topLeading
               )
               .background(Color("BackgroundPrimary"))
           }
       }
   }

   #Preview {
       HomeView()
   }
