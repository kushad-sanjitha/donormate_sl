//
//  DonationHistoryRow.swift
//  DonorMateSL
//
//  Created by user300742 on 10/13/26.
//

import SwiftUI

struct DonationHistoryRow: View {
    let date: String
       let locationAndType: String
       let recordLabel: String
       let isLast: Bool

       var body: some View {
           ZStack(
               alignment: .topLeading
           ) {

               if !isLast {
                   Rectangle()
                       .fill(Color("BorderPrimary"))
                       .frame(width: 2)
                       .frame(
                           maxHeight: .infinity,
                           alignment: .top
                       )
                       .offset(x: 6)
               }

               HStack(
                   alignment: .top,
                   spacing: 0
               ) {

                   ZStack {
                       Circle()
                           .fill(Color("DonorRedSoft"))
                           .frame(width: 14, height: 14)

                       Circle()
                           .fill(Color("DonorRed"))
                           .frame(width: 8, height: 8)
                   }
                   .frame(
                       width: 22,
                       alignment: .leading
                   )
                   .accessibilityHidden(true)

                   VStack(
                       alignment: .leading,
                       spacing: 4
                   ) {

                       Text(date)
                           .font(.system(size: 15, weight: .bold))
                           .foregroundStyle(Color("TextPrimary"))

                       Text(locationAndType)
                           .font(.system(size: 12))
                           .foregroundStyle(Color("TextSecondary"))
                           .fixedSize(
                               horizontal: false,
                               vertical: true
                           )

                       Text(recordLabel)
                           .font(.system(size: 11))
                           .foregroundStyle(Color("TextSecondary"))
                   }
                   .frame(
                       maxWidth: .infinity,
                       alignment: .leading
                   )
               }
               .padding(
                   .bottom,
                   isLast ? 0 : 18
               )
           }
           .frame(
               maxWidth: .infinity,
               alignment: .leading
           )
       }
   }

   #Preview {
       VStack(spacing: 0) {

           DonationHistoryRow(
               date: "18 May 2026",
               locationAndType: "Matara Blood Bank · Whole blood",
               recordLabel: "Blood-bank record",
               isLast: false
           )

           DonationHistoryRow(
               date: "16 January 2026",
               locationAndType: "Matara · Whole blood",
               recordLabel: "Blood-bank record",
               isLast: false
           )

           DonationHistoryRow(
               date: "12 September 2025",
               locationAndType: "Matara · Whole blood",
               recordLabel: "Blood-bank record",
               isLast: false
           )

           DonationHistoryRow(
               date: "06 May 2025",
               locationAndType: "Matara · Whole blood",
               recordLabel: "Blood-bank record",
               isLast: true
           )
       }
       .padding(18)
       .background(Color("BackgroundPrimary"))
   }
