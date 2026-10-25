//
//  NotificationPreferencesView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/25/26.
//

import SwiftUI

struct NotificationPreferencesView: View {
    @ObservedObject var store: NotificationPreferencesStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            ScreenNavigationHeader(
                title: "Notifications",
                onBack: { dismiss() }
            )

            ScreenScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if let errorMessage = store.errorMessage {
                        NeutralMessageCard(
                            systemImage: "exclamationmark.triangle",
                            title: "Notification preferences unavailable",
                            detail: errorMessage
                        )
                        .padding(.bottom, 16)
                    }

                    Text("REMINDERS")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color("TextSecondary"))
                        .padding(.bottom, 8)

                    VStack(spacing: 10) {
                        ForEach(NotificationPreferenceKind.allCases) { kind in
                            preferenceRow(for: kind)
                        }
                    }

                    informationCard
                        .padding(.top, 16)
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
        }
        .background(Color("BackgroundPrimary"))
        .toolbar(.hidden, for: .navigationBar)
    }

    private func preferenceRow(for kind: NotificationPreferenceKind) -> some View {
        Toggle(isOn: Binding(
            get: { store.isEnabled(kind) },
            set: { store.setEnabled($0, for: kind) }
        )) {
            VStack(alignment: .leading, spacing: 4) {
                Text(kind.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color("TextPrimary"))

                Text(kind.detail)
                    .font(.system(size: 12))
                    .foregroundStyle(Color("TextSecondary"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .tint(Color("DonorRed"))
        .accessibilityLabel(kind.title)
        .accessibilityHint(kind.detail)
        .padding(14)
        .background(Color("SurfacePrimary"))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("BorderPrimary"), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var informationCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color("InfoBlue"))
                .accessibilityHidden(true)

            Text("Urgent alerts are informational. DonorMate does not decide medical eligibility.")
                .font(.system(size: 12))
                .foregroundStyle(Color("TextPrimary"))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(Color("InfoBlueSoft"))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("InfoBlueBorder"), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview("Screen 31 - Notification Preferences") {
    NavigationStack {
        NotificationPreferencesView(store: NotificationPreferencesStore())
    }
}
