//
//  SignInView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/4/26.
//

import SwiftUI

struct SignInView: View {
    @State private var email = ""
       @State private var password = ""
       @State private var isPasswordVisible = false

       var onBack: () -> Void = {}
       var onForgotPassword: () -> Void = {}
       var onCreateAccount: () -> Void = {}
       var onSignIn: () -> Void = {}

       var body: some View {
           VStack(spacing: 0) {

               HStack {

                   Button {
                       onBack()
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
                           .frame(width: 44, height: 44)
                           .contentShape(Rectangle())
                   }
                   .buttonStyle(.plain)
                   .accessibilityLabel("Back")

                   Spacer()

                   Text("Sign In")
                       .font(.system(size: 15, weight: .bold))
                       .foregroundStyle(Color("TextPrimary"))

                   Spacer()

                   Color.clear
                       .frame(width: 44, height: 44)
               }

               Spacer()
                   .frame(height: 18)

               VStack(
                   alignment: .leading,
                   spacing: 0
               ) {

                   Text("WELCOME BACK")
                       .font(.system(size: 12, weight: .heavy))
                       .foregroundStyle(Color("DonorRed"))

                   Text("Sign in to DonorMate.")
                       .font(.system(size: 28, weight: .heavy))
                       .foregroundStyle(Color("TextPrimary"))
                       .padding(.top, 10)

                   Text("Use your DonorMate account details.")
                       .font(.system(size: 14))
                       .foregroundStyle(Color("TextSecondary"))
                       .lineSpacing(3)
                       .padding(.top, 10)
               }
               .frame(
                   maxWidth: .infinity,
                   alignment: .leading
               )

               Spacer()
                   .frame(height: 24)

               VStack(spacing: 16) {

                   VStack(
                       alignment: .leading,
                       spacing: 6
                   ) {

                       Text("Email")
                           .font(.system(size: 12, weight: .semibold))
                           .foregroundStyle(Color("TextPrimary"))

                       TextField(
                           "name@example.com",
                           text: $email
                       )
                       .font(.system(size: 14))
                       .foregroundStyle(Color("TextPrimary"))
                       .textInputAutocapitalization(.never)
                       .autocorrectionDisabled()
                       .keyboardType(.emailAddress)
                       .submitLabel(.next)
                       .padding(.horizontal, 14)
                       .frame(height: 52)
                       .background(Color("SurfacePrimary"))
                       .overlay {
                           RoundedRectangle(cornerRadius: 13)
                               .stroke(
                                   Color("BorderPrimary"),
                                   lineWidth: 1
                               )
                       }
                       .clipShape(
                           RoundedRectangle(cornerRadius: 13)
                       )
                   }

                   VStack(
                       alignment: .leading,
                       spacing: 6
                   ) {

                       Text("Password")
                           .font(.system(size: 12, weight: .semibold))
                           .foregroundStyle(Color("TextPrimary"))

                       HStack(spacing: 10) {

                           Group {
                               if isPasswordVisible {
                                   TextField(
                                       "Password",
                                       text: $password
                                   )
                               } else {
                                   SecureField(
                                       "Password",
                                       text: $password
                                   )
                               }
                           }
                           .font(.system(size: 14))
                           .foregroundStyle(Color("TextPrimary"))
                           .textInputAutocapitalization(.never)
                           .autocorrectionDisabled()
                           .submitLabel(.go)

                           Button {
                               isPasswordVisible.toggle()
                           } label: {
                               Image(
                                   systemName: isPasswordVisible
                                   ? "eye.slash"
                                   : "eye"
                               )
                               .font(.system(size: 16, weight: .semibold))
                               .foregroundStyle(Color("TextSecondary"))
                               .frame(width: 32, height: 32)
                               .contentShape(Rectangle())
                           }
                           .buttonStyle(.plain)
                           .accessibilityLabel(
                               isPasswordVisible
                               ? "Hide password"
                               : "Show password"
                           )
                       }
                       .padding(.horizontal, 14)
                       .frame(height: 52)
                       .background(Color("SurfacePrimary"))
                       .overlay {
                           RoundedRectangle(cornerRadius: 13)
                               .stroke(
                                   Color("BorderPrimary"),
                                   lineWidth: 1
                               )
                       }
                       .clipShape(
                           RoundedRectangle(cornerRadius: 13)
                       )
                   }

                   HStack {
                       Spacer()

                       Button {
                           onForgotPassword()
                       } label: {
                           Text("Forgot password?")
                               .font(.system(size: 13, weight: .bold))
                               .foregroundStyle(Color("DonorRed"))
                               .padding(.vertical, 8)
                       }
                       .buttonStyle(.plain)
                   }

                   Button {
                       onSignIn()
                   } label: {
                       Text("Sign In")
                           .font(.system(size: 15, weight: .bold))
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
               }

               Spacer()

               HStack(spacing: 5) {

                   Text("New to DonorMate?")
                       .font(.system(size: 13))
                       .foregroundStyle(Color("TextSecondary"))

                   Button {
                       onCreateAccount()
                   } label: {
                       Text("Create account")
                           .font(.system(size: 13, weight: .bold))
                           .foregroundStyle(Color("DonorRed"))
                           .padding(.vertical, 8)
                   }
                   .buttonStyle(.plain)
               }
               .padding(.bottom, 26)
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
       SignInView(
           onBack: {
               print("Back tapped")
           },
           onForgotPassword: {
               print("Forgot password tapped")
           },
           onCreateAccount: {
               print("Create account tapped")
           },
           onSignIn: {
               print("Sign In tapped")
           }
       )
   }
