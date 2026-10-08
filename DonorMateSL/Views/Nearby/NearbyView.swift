//
//  NearbyView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/8/26.
//

import SwiftUI

struct NearbyView: View {
    var body: some View {
        NavigationStack {
            VStack(
                alignment: .leading,
                spacing: 10
            ) {

                Text("Nearby")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(Color("TextPrimary"))

                Text("Donation places near you")
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
    NearbyView()
}
