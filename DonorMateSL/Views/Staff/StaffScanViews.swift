//
//  StaffScanViews.swift
//  DonorMateSL
//
//  Created by user300742 on 10/29/26.
//

import Foundation
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import VisionKit

struct StaffScanCaptureView: View {
    let onCaptured: ([Data], StaffScanSource) -> Void
    let onBack: () -> Void
    let onError: (String) -> Void

    @State private var showCamera = false
    @State private var showFileImporter = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isLoadingPhoto = false

    var body: some View {
        StaffPageHeading(
            eyebrow: "Identity verification",
            title: "Capture identity card",
            subtitle: "Keep the full card visible, with clear text and no glare."
        )

        StaffPanel {
            VStack(spacing: 16) {
                Image(systemName: "person.text.rectangle")
                    .font(.system(size: 52, weight: .light))
                    .foregroundStyle(Color("DonorRed"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 146)
                    .background(Color("DonorRedSoft"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .accessibilityHidden(true)

                Text("Scan the front of the NIC. You can include the reverse side when needed.")
                    .font(.subheadline)
                    .foregroundStyle(Color("TextSecondary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }

        if VNDocumentCameraViewController.isSupported {
            StaffActionButton(title: "Open Camera") { showCamera = true }
        } else {
            StaffNotice(message: "The camera scanner is unavailable here. You can select a clear photo or image file instead.")
        }

        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            StaffActionButtonLabel(title: "Choose Photo", primary: !VNDocumentCameraViewController.isSupported)
        }
        .buttonStyle(.plain)
        .disabled(isLoadingPhoto)

        Button { showFileImporter = true } label: {
            StaffActionButtonLabel(title: "Browse Files", primary: false)
        }
        .buttonStyle(.plain)
        .disabled(isLoadingPhoto)

        if isLoadingPhoto {
            HStack(spacing: 10) {
                ProgressView().tint(Color("DonorRed"))
                Text("Preparing photo…")
                    .font(.subheadline)
                    .foregroundStyle(Color("TextSecondary"))
            }
            .accessibilityElement(children: .combine)
        }

        StaffActionButton(title: "Back to Instructions", primary: false, action: onBack)

        StaffNotice(message: "Captured images are read on this device. Recognition alone does not confirm a donor's identity.")

        .sheet(isPresented: $showCamera) {
            StaffDocumentCameraView(
                onCaptured: { pages in
                    showCamera = false
                    onCaptured(pages, .camera)
                },
                onCancelled: { showCamera = false },
                onFailed: { message in
                    showCamera = false
                    onError(message)
                }
            )
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.image]) { outcome in
            switch outcome {
            case .success(let url):
                let accessGranted = url.startAccessingSecurityScopedResource()
                defer { if accessGranted { url.stopAccessingSecurityScopedResource() } }

                do {
                    let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                    guard size <= StaffTextRecognitionService.maximumImageBytes else {
                        onError(StaffTextRecognitionError.imageTooLarge.localizedDescription)
                        return
                    }
                    let imageData = try Data(contentsOf: url)
                    onCaptured([imageData], .files)
                } catch {
                    onError("This image couldn't be opened. Please choose another file.")
                }
            case .failure:
                onError("The image couldn't be selected. Please try again.")
            }
        }
        .onChange(of: selectedPhoto) { _, photo in
            guard let photo else { return }
            isLoadingPhoto = true
            Task {
                defer {
                    isLoadingPhoto = false
                    selectedPhoto = nil
                }
                do {
                    guard let imageData = try await photo.loadTransferable(type: Data.self) else {
                        onError("This photo couldn't be opened. Please choose another image.")
                        return
                    }
                    onCaptured([imageData], .photoLibrary)
                } catch {
                    onError("This photo couldn't be opened. Please choose another image.")
                }
            }
        }
    }
}

struct StaffScanProcessingView: View {
    var body: some View {
        StaffPageHeading(
            eyebrow: "Identity verification",
            title: "Reading identity details",
            subtitle: "Please wait while the text on the card is read."
        )

        StaffPanel {
            VStack(spacing: 18) {
                ProgressView()
                    .controlSize(.large)
                    .tint(Color("DonorRed"))
                    .accessibilityLabel("Reading card text")
                Text("Reading card text…")
                    .font(.headline)
                    .foregroundStyle(Color("TextPrimary"))
                Text("Keep this screen open until the scan is complete.")
                    .font(.subheadline)
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 36)
        }
    }
}

struct StaffScanReviewView: View {
    let result: StaffScanResult
    let onScanAgain: () -> Void
    let onFinish: () -> Void

    var body: some View {
        StaffPageHeading(
            eyebrow: "Identity verification",
            title: "Card text ready",
            subtitle: "Check the text below against the original identity card."
        )

        StaffPanel {
            VStack(alignment: .leading, spacing: 14) {
                Label("Text captured", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(Color("TextPrimary"))

                Text("Source: \(result.source.displayName)")
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))

                Divider()

                ForEach(Array(result.lines.enumerated()), id: \.offset) { entry in
                    Text(entry.element.text)
                        .font(.system(size: 15))
                        .foregroundStyle(Color("TextPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
            }
        }

        StaffNotice(
            message: "The card has not been verified. Review all identity details before comparing them with an official donor record."
        )

        StaffActionButton(title: "Scan Again", action: onScanAgain)
        StaffActionButton(title: "Finish", primary: false, action: onFinish)
    }
}
