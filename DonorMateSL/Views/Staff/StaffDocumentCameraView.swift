//
//  StaffDocumentCameraView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/29/26.
//

import Foundation
import SwiftUI
import VisionKit

struct StaffDocumentCameraView: UIViewControllerRepresentable {
    let onCaptured: ([Data]) -> Void
    let onCancelled: () -> Void
    let onFailed: (String) -> Void

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let parent: StaffDocumentCameraView

        init(parent: StaffDocumentCameraView) {
            self.parent = parent
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            guard scan.pageCount <= StaffTextRecognitionService.maximumPages else {
                finish(controller) {
                    self.parent.onFailed(
                        StaffTextRecognitionError.tooManyPages.localizedDescription
                    )
                }
                return
            }

            let pages = (0..<scan.pageCount).compactMap {
                scan.imageOfPage(at: $0).jpegData(compressionQuality: 0.88)
            }
            guard pages.count == scan.pageCount else {
                finish(controller) {
                    self.parent.onFailed(
                        StaffTextRecognitionError.noImage.localizedDescription
                    )
                }
                return
            }

            finish(controller) { self.parent.onCaptured(pages) }
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            finish(controller, completion: parent.onCancelled)
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFailWithError error: Error
        ) {
            finish(controller) {
                self.parent.onFailed("The camera could not complete the scan. Please try again.")
            }
        }

        private func finish(
            _ controller: VNDocumentCameraViewController,
            completion: @escaping () -> Void
        ) {
            controller.dismiss(animated: true, completion: completion)
        }
    }
}
