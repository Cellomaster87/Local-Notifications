//
//  ViewController.swift
//  Local Notifications
//
//  Created by Michele Galvagno on 21/04/2019.
//  Copyright © 2019 Michele Galvagno. All rights reserved.
//

import UserNotifications
import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
    }
    
    @objc func registerLocal() {
        // request permission to show notifications
        let center = UNUserNotificationCenter.current() // this is what let us post content on the user's screen
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh!")
            }
        }
    }
    
    @objc func scheduleLocal() {
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        // what content to show
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = .default
        
        // when to show it (trigger)
//        var dateComponents = DateComponents()
//        dateComponents.hour = 10
//        dateComponents.minute = 30
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // request (combination of content and trigger
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more...", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([category])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // pull out the buried userInfo dictionary
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
        
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock
                let swipeAC = UIAlertController(title: "Congratulations", message: "You launched the app by unlocking your phone!", preferredStyle: .alert)
                swipeAC.addAction(UIAlertAction(title: "Thanks!", style: .default))
                
                present(swipeAC, animated: true)
                print("Default identifier")
            case "show":
                // the user tapped our "show more info..." button
                let tapAC = UIAlertController(title: "Victory!", message: #"You launched the app after tapping the "Show more info" button"#, preferredStyle: .alert)
                tapAC.addAction(UIAlertAction(title: "Amazing!", style: .default))
                
                present(tapAC, animated: true)
                print("Show more information...")
            default:
                break
            }
        }
        
        // you must call the completion handler when you are done
        completionHandler()
    }
}

