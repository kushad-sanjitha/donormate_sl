# DonorMate SL

DonorMate SL is an iOS blood donation support application developed using Swift and SwiftUI for my university coursework.

The application helps donors view their donation history, check their next possible donation date, find nearby blood banks and donation camps, receive location alerts, and view urgent blood needs. It also includes a staff verification feature.

## Technologies Used

- Swift and SwiftUI
- Xcode
- Firebase Authentication
- Cloud Firestore
- MapKit and Core Location
- VisionKit and Vision
- WidgetKit
- UserNotifications

## How to Run the Application

1. Download or clone this repository:

   `https://github.com/kushadsanjitha/donormate_sl`

2. Open the project folder on a Mac with Xcode installed.

3. Open `DonorMateSL.xcodeproj` in Xcode.

4. Allow Xcode to resolve the Firebase Swift Package dependencies.

5. Ensure the Firebase configuration file, `DonorMateSL/GoogleService-Info.plist`, is available. If it is not included in the downloaded project, contact the developer to obtain it privately.

6. Select the `DonorMateSL` scheme.

7. Select an iPhone simulator. The application was developed and tested using the iPhone 17 Pro simulator with iOS 26.2.

8. Click Run or press `Command + R`.

An internet connection is required for Firebase services.

## Firebase Backend

DonorMate SL uses Firebase Authentication for user sign-in and Cloud Firestore for application data.

The Firestore database contains collections including:

- `users`
- `donorRecords`
- `donationLocations`
- `urgentBloodNeeds`
- `staffMembers`

The application connects to the configured Firebase project automatically. There is no separate backend server to install.

The coursework uses demonstration data for testing.

## Marker Test Access

Two test accounts are available for assessment:

**Donor Test Account**

- Account type: Donor
- Donor reference: `DM-248013`
- Used to test donor records, donation readiness, nearby locations and other donor features.

**Staff Test Account**

- Account type: Staff
- Used to test staff sign-in, donor record lookup and identity verification.

The test account email addresses and passwords will be provided directly to the lecturer through a private channel. They are not included in this public repository.

## Testing Notes

- The main application can be tested using an iPhone simulator.
- Location alerts can be tested using simulated GPS coordinates.
- Staff document recognition can be tested using sample images from the simulator's photo library.
- Some camera and widget features depend on device capabilities, permissions and signing configuration.
- The application uses demonstration records and is not connected to a live hospital blood donation system.

## Developer

Kushad Sanjitha

NIBM — BSc (Hons) Computing

iOS Application Development Coursework
