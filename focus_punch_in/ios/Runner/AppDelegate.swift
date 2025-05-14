import Flutter
import UIKit

import flutter_local_notifications
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
       GeneratedPluginRegistrant.register(with: registry)
    }

    // Nếu muốn nhận thông báo khi app đang foreground
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self
    }

    // Đăng ký các plugin mặc định
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
