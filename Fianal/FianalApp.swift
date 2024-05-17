import SwiftUI

@main
struct FianalApp: App {
    @State private var inputImage: UIImage? = nil
    @State private var stickerImageName: String = "defaultImageName"  // Default image name for stickers
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
      }
    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .onAppear {
                    // طلب إذن الإشعارات عند تشغيل التطبيق
                    NotificationManager.shared.requestAuthorization()
                }
        }
    }
}
