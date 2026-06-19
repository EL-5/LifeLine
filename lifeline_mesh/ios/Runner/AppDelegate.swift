import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Replace "YOUR_IOS_API_KEY_HERE" with your actual Google Maps API key
    GMSServices.provideAPIKey("AIzaSyBLZJbPDMkn91YVgMxeP6TGFN_phMwTkq8")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
