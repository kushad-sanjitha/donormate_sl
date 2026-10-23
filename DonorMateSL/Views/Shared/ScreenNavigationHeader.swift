//
//  ScreenNavigationHeader.swift
//  DonorMateSL
//
//  Created by user300742 on 10/23/26.
//

import SwiftUI

struct ScreenNavigationHeader: View {

    let title: String
    let isBackDisabled: Bool
    let trailingSystemImage: String?
    let trailingAccessibilityLabel: String?
    let onBack: () -> Void
    let onTrailingAction: (() -> Void)?

    init(
        title: String,
        isBackDisabled: Bool = false,
        trailingSystemImage: String? = nil,
        trailingAccessibilityLabel: String? = nil,
        onBack: @escaping () -> Void,
        onTrailingAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.isBackDisabled = isBackDisabled
        self.trailingSystemImage = trailingSystemImage
        self.trailingAccessibilityLabel = trailingAccessibilityLabel
        self.onBack = onBack
        self.onTrailingAction = onTrailingAction
    }

    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color("TextPrimary"))
                .lineLimit(1)

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
                .disabled(isBackDisabled)
                .accessibilityLabel("Back")

                Spacer()

                if let trailingSystemImage,
                   let onTrailingAction {
                    Button {
                        onTrailingAction()
                    } label: {
                        Image(systemName: trailingSystemImage)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color("TextPrimary"))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        trailingAccessibilityLabel ?? "Action"
                    )
                } else {
                    Color.clear
                        .frame(width: 44, height: 44)
                }
            }
        }
        .frame(minHeight: 44)
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .background(Color("BackgroundPrimary"))
    }
}

#Preview {
    ScreenNavigationHeader(
        title: "Create Account",
        onBack: {}
    )
}

