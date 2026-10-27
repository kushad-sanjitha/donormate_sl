//
//  AccountAccessView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/4/26.
//

import SwiftUI

struct AccountAccessView: View {
    var onSignIn: () -> Void = {}
       var onCreateAccount: () -> Void = {}
       var onStaffSignIn: () -> Void = {}

       var body: some View {
           VStack(spacing: 0) {

               Spacer()
                   .frame(height: 38)

               ZStack {
                   RoundedRectangle(cornerRadius: 24)
                       .fill(
                           LinearGradient(
                               colors: [
                                   Color("DonorRedSoft"),
                                   Color("SurfacePrimary")
                               ],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing
                           )
                       )
                       .frame(width: 120, height: 120)
                       .overlay {
                           RoundedRectangle(cornerRadius: 24)
                               .stroke(
                                   Color("DonorRedBorder"),
                                   lineWidth: 1
                               )
                       }

                   Image(systemName: "person.crop.circle.fill")
                       .font(
                           .system(
                               size: 54,
                               weight: .semibold
                           )
                       )
                       .foregroundStyle(Color("DonorRed"))
                       .accessibilityHidden(true)
               }

               Spacer()
                   .frame(height: 24)

               VStack(spacing: 10) {

                   Text("Welcome to DonorMate")
                       .font(
                           .system(
                               size: 28,
                               weight: .heavy
                           )
                       )
                       .foregroundStyle(Color("TextPrimary"))
                       .multilineTextAlignment(.center)

                   Text(
                       "Sign in to access your donor-linked information, or create a DonorMate account."
                   )
                   .font(.system(size: 14))
                   .foregroundStyle(Color("TextSecondary"))
                   .multilineTextAlignment(.center)
                   .lineSpacing(3)
               }
               .padding(.horizontal, 8)

               Spacer()
                   .frame(height: 34)

               VStack(spacing: 10) {

                   Button {
                       onSignIn()
                   } label: {
                       Text("Sign In")
                           .font(
                               .system(
                                   size: 15,
                                   weight: .bold
                               )
                           )
                           .foregroundStyle(.white)
                           .frame(
                               maxWidth: .infinity,
                               minHeight: 48
                           )
                           .background(Color("DonorRed"))
                           .clipShape(
                               RoundedRectangle(cornerRadius: 14)
                           )
                   }
                   .buttonStyle(.plain)

                   Button {
                       onCreateAccount()
                   } label: {
                       Text("Create Account")
                           .font(
                               .system(
                                   size: 15,
                                   weight: .bold
                               )
                           )
                           .foregroundStyle(Color("TextPrimary"))
                           .frame(
                               maxWidth: .infinity,
                               minHeight: 48
                           )
                           .background(Color("SurfacePrimary"))
                           .overlay {
                               RoundedRectangle(cornerRadius: 14)
                                   .stroke(
                                       Color("BorderPrimary"),
                                       lineWidth: 1
                                   )
                           }
                           .clipShape(
                               RoundedRectangle(cornerRadius: 14)
                           )
                   }
                   .buttonStyle(.plain)
               }

               Button(action: onStaffSignIn) {
                   Label("Staff Sign In", systemImage: "person.crop.rectangle")
                       .font(.system(size: 15, weight: .bold))
                       .foregroundStyle(Color("TextPrimary"))
                       .frame(maxWidth: .infinity, minHeight: 48)
                       .background(Color("SurfacePrimary"))
                       .overlay {
                           RoundedRectangle(cornerRadius: 14)
                               .stroke(Color("BorderPrimary"), lineWidth: 1)
                       }
                       .clipShape(RoundedRectangle(cornerRadius: 14))
               }
               .buttonStyle(.plain)
               .padding(.top, 10)
               .accessibilityHint("Sign in using an account authorised for staff verification")

               Spacer()
                   .frame(height: 18)

               HStack(
                   alignment: .top,
                   spacing: 10
               ) {

                   ZStack {
                       RoundedRectangle(cornerRadius: 10)
                           .fill(
                               Color("InfoBlue")
                                   .opacity(0.10)
                           )
                           .frame(
                               width: 36,
                               height: 36
                           )

                       Image(systemName: "info.circle.fill")
                           .font(
                               .system(
                                   size: 18,
                                   weight: .semibold
                               )
                           )
                           .foregroundStyle(Color("InfoBlue"))
                   }
                   .accessibilityHidden(true)

                   Text(
                       "Donor records remain controlled by the blood bank. Donors can view linked records but cannot create or edit donation entries."
                   )
                   .font(.system(size: 12))
                   .foregroundStyle(Color("TextPrimary"))
                   .lineSpacing(2)

                   Spacer(minLength: 0)
               }
               .padding(14)
               .background(Color("InfoBlueSoft"))
               .overlay {
                   RoundedRectangle(cornerRadius: 16)
                       .stroke(
                           Color("InfoBlue").opacity(0.18),
                           lineWidth: 1
                       )
               }
               .clipShape(
                   RoundedRectangle(cornerRadius: 16)
               )

               Spacer()
           }
           .padding(.horizontal, 18)
           .padding(.top, 18)
           .frame(
               maxWidth: .infinity,
               maxHeight: .infinity
           )
           .background(Color("BackgroundPrimary"))
       }
   }

   #Preview {
       AccountAccessView(
           onSignIn: {
               print("Sign In tapped")
           },
           onCreateAccount: {
               print("Create Account tapped")
           }
       )
   }
