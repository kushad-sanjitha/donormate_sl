//
//  ScreenScrollView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/23/26.
//

import SwiftUI

struct ScreenScrollView<Content: View>: View {

    private let content: Content

    init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }

    var body: some View {
        ScrollView {
            content
                .padding(.bottom, 12)
        }
        .scrollDismissesKeyboard(.interactively)
        .scrollBounceBehavior(.basedOnSize)
        .scrollClipDisabled(false)
        .background(Color("BackgroundPrimary"))
    }
}

private struct TabBarContentClearanceModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .scrollBounceBehavior(.basedOnSize)
            .safeAreaInset(
                edge: .bottom,
                spacing: 0
            ) {
                Color.clear
                    .frame(height: 8)
                    .allowsHitTesting(false)
            }
    }
}

extension View {

    func tabBarContentClearance() -> some View {
        modifier(
            TabBarContentClearanceModifier()
        )
    }
}
