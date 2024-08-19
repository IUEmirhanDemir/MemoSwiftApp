//
//  NotifyManager.swift
//  MemoSwiftApp
//
//  Created by Emirhan Demir on 16.08.24.
//


import Foundation
import UserNotifications

/// `NotifyManager` is a singleton class responsible for managing local notifications in the MemoSwiftApp.
class NotifyManager {
    
    /// Shared instance of `NotifyManager` to be used throughout the app.
    static let shared = NotifyManager()

    /// Private initializer to ensure `NotifyManager` is only instantiated once.
    private init() {}

    /// Requests permission from the user to display notifications.
    ///
    /// This method prompts the user with an alert requesting permission to display notifications
    /// with alerts, badges, and sounds. The result of the permission request is handled in the completion handler.
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    /// Schedules a local notification for a specific memo.
    ///
    /// This method creates a local notification for the provided `MemoData` and schedules it to be delivered at the specified `reminderDate`.
    ///
    /// - Parameter memo: The `MemoData` instance for which the notification is scheduled. The title and details of the memo are used in the notification content.
    ///
    /// - Throws: An error if there is an issue scheduling the notification.
    ///
    /// - Returns: Void.
    func scheduleNotification(for memo: MemoData) {
        let content = UNMutableNotificationContent()
        content.title = memo.title
        content.body = memo.details
        content.sound = UNNotificationSound.default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: memo.reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: memo.id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}
