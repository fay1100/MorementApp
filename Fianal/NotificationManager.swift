//import UserNotifications
//
//class NotificationManager {
//    static let shared = NotificationManager()
//    
//    private init() {}
//
//    func requestNotificationPermission() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if let error = error {
//                print("Request authorization failed: \(error)")
//            }
//        }
//    }
//
//    func scheduleNotifications(for creationDate: Date, boardID: String, memberIDs: [String]) {
//        let notificationCenter = UNUserNotificationCenter.current()
//
//        // Define the notification times for testing
//        let notificationTimes: [(TimeInterval, String)] = [
//            (120, "Board created 2 minutes ago!"),  // 2 minutes
//            (240, "Board created 4 minutes ago!"),  // 4 minutes
//            (300, "Board created 5 minutes ago!"),  // 5 minutes
//            (82800, "Board created 23 hours ago!")  // 23 hours (للتأكد من إضافة إشعار 23 ساعة)
//        ]
//
//        let now = Date()
//
//        for (interval, message) in notificationTimes {
//            let triggerDate = Calendar.current.date(byAdding: .second, value: Int(interval), to: creationDate)!
//
//            if triggerDate > now {
//                let content = UNMutableNotificationContent()
//                content.title = "Board Notification"
//                content.body = message
//                content.sound = .default
//
//                for memberID in memberIDs {
//                    content.userInfo = ["memberID": memberID]
//
//                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerDate.timeIntervalSince(now), repeats: false)
//                    let request = UNNotificationRequest(identifier: "\(boardID)_\(interval)_\(memberID)", content: content, trigger: trigger)
//
//                    notificationCenter.add(request) { error in
//                        if let error = error {
//                            print("Error scheduling notification: \(error)")
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
