//
//  NeutralMessageCard.swift
//  DonorMateSL
//
//  Created by user300742 on 10/13/26.
//

import SwiftUI

struct NeutralMessageCard: View {
    enum Style {
            case standard
            case compact
        }

        let systemImage: String
        let title: String
        let detail: String
        let style: Style
        let iconForeground: Color

        init(
            systemImage: String,
            title: String,
            detail: String,
            style: Style = .standard,
            iconForeground: Color = Color("TextSecondary")
        ) {
            self.systemImage = systemImage
            self.title = title
            self.detail = detail
            self.style = style
            self.iconForeground = iconForeground
        }

        private var iconSize: CGFloat {
            switch style {
            case .standard:
                return 40
            case .compact:
                return 34
            }
        }

        private var detailFontSize: CGFloat {
            switch style {
            case .standard:
                return 12
            case .compact:
                return 11
            }
        }

        var body: some View {
            HStack(
                alignment: .center,
                spacing: 10
            ) {

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("NeutralSoft"))
                        .frame(
                            width: iconSize,
                            height: iconSize
                        )

                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(iconForeground)
                }
                .accessibilityHidden(true)

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                    Text(detail)
                        .font(.system(size: detailFontSize))
                        .foregroundStyle(Color("TextSecondary"))
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
            .padding(14)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(Color("SurfaceSecondary"))
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
        }
    }

    #Preview {
        VStack(spacing: 14) {

            NeutralMessageCard(
                systemImage: "lock.fill",
                title: "View-only record",
                detail: "This donation cannot be changed in DonorMate.",
                style: .standard,
                iconForeground: Color("ReminderAmber")
            )

            NeutralMessageCard(
                systemImage: "info.circle.fill",
                title: "Final eligibility is confirmed by staff.",
                detail: "DonorMate only tracks the recorded waiting period.",
                style: .compact
            )
        }
        .padding(18)
        .background(Color("BackgroundPrimary"))
    }
