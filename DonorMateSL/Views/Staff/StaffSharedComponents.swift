//
//  StaffSharedComponents.swift
//  DonorMateSL
//
//  Created by user300742 on 10/27/26.
//

import SwiftUI

struct StaffFormField<Content: View>: View {
    let title: String
    private let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color("TextPrimary"))

            content
                .font(.system(size: 14))
                .foregroundStyle(Color("TextPrimary"))
                .padding(.horizontal, 14)
                .frame(height: 52)
                .background(Color("SurfacePrimary"))
                .clipShape(RoundedRectangle(cornerRadius: 13))
                .overlay {
                    RoundedRectangle(cornerRadius: 13)
                        .stroke(Color("BorderPrimary"), lineWidth: 1)
                }
        }
    }
}

struct StaffPanel<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("SurfacePrimary"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("BorderPrimary"), lineWidth: 1)
            }
    }
}

struct StaffPageHeading: View {
    let eyebrow: String
    let title: String
    var subtitle: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(eyebrow.uppercased())
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color("DonorRed"))
            Text(title)
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(Color("TextPrimary"))
                .fixedSize(horizontal: false, vertical: true)
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(Color("TextSecondary"))
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct StaffActionButton: View {
    let title: String
    var primary = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(primary ? Color.white : Color("TextPrimary"))
                .frame(maxWidth: .infinity, minHeight: 48)
                .padding(.horizontal, 8)
                .background(primary ? Color("DonorRed") : Color("SurfacePrimary"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    if !primary {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color("BorderPrimary"), lineWidth: 1)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

struct StaffNotice: View {
    let message: String
    var icon = "info.circle.fill"
    var tint: Color = Color("InfoBlue")

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon).foregroundStyle(tint).accessibilityHidden(true)
            Text(message)
                .font(.system(size: 12))
                .foregroundStyle(Color("TextPrimary"))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("InfoBlueSoft"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(tint.opacity(0.18), lineWidth: 1)
        }
    }
}

struct StaffSidebar: View {
    let staff: StaffIdentity
    let active: StaffSection
    let onDashboard: () -> Void
    let onVerify: () -> Void
    let onExit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "drop.fill")
                    .font(.title2).foregroundStyle(Color("DonorRed"))
                    .frame(width: 45, height: 45)
                    .background(Color("DonorRedSoft"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 3) {
                    Text("DonorMate SL").font(.headline)
                    Text(staff.displayName).font(.caption).foregroundStyle(Color("TextSecondary"))
                }
            }
            .padding(.bottom, 12)

            item("Dashboard", symbol: "square.grid.2x2.fill", active: active == .dashboard, action: onDashboard)
            item("Verify Donor", symbol: "person.text.rectangle", active: active == .verifyDonor, action: onVerify)

            Spacer()
            StaffNotice(message: "Signed in at \(staff.locationName). Verification requires staff review.")
            item("Sign Out", symbol: "rectangle.portrait.and.arrow.right", active: false, action: onExit)
        }
        .padding(18)
        .frame(maxHeight: .infinity)
        .background(Color("SurfacePrimary"))
    }

    private func item(
        _ title: String,
        symbol: String,
        active: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(active ? .bold : .medium))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(active ? Color("DonorRedSoft") : Color.clear)
                .foregroundStyle(active ? Color("DonorRed") : Color("TextPrimary"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
