//
//  DonorMateSLApp.swift
//  DonorMateSL
//
//  Created by user300742 on 10/4/26.
//

import FirebaseCore
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        guard let defaultApp = FirebaseApp.app() else { return false }
        FirebaseApp.configure(name: "DonorMateStaff", options: defaultApp.options)
        return true
    }
}

@main
struct DonorMateSLApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
