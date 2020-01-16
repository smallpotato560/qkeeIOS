//
//  AppDelegate.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/6/22.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData
import UserNotifications
import WebKit
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    /*
    // MARK: APP關閉，點擊橫幅推播作動的func
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // 印出後台送出的推播訊息(JSON 格式)
        let userInfo = response.notification.request.content.userInfo //推播訊息
        print("背景userInfo: \(userInfo)")
    }*/
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 在程式一啟動即詢問使用者是否接受圖文(alert)、聲音(sound)、數字(badge)三種類型的通知
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge, .carPlay], completionHandler: { (granted, error) in
            if granted {
                //print("允許")
            } else {
                //print("不允許")
            }
        })
        
        UIApplication.shared.registerForRemoteNotifications()
        
        // 註冊遠程通知
        application.registerForRemoteNotifications()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
              application.registerUserNotificationSettings(settings)
         
        }
        
        application.registerForRemoteNotifications()

        Messaging.messaging().delegate = self
        FirebaseApp.configure()
        
        
        if Messaging.messaging().fcmToken != nil {
            let deviceTokenString = String(Messaging.messaging().fcmToken!)
            print("deviceTokenString:\(deviceTokenString)")

            let myEntityName = "UserInfo"
            let myContext =
                (UIApplication.shared.delegate as! AppDelegate)
                    .persistentContainer.viewContext
            let coreDataConnect = CoreDataConnect(context: myContext)
            
            // select
            let selectResult = coreDataConnect.retrieve(
                myEntityName, predicate: nil, sort: nil, limit: nil)
            
            if let results = selectResult {
                for result in results {
                    
                    print("userid: \(result.value(forKey: "userid")!),username: \(result.value(forKey: "username")!)")
                    let userid = result.value(forKey: "userid")! as? Int
                    let username = result.value(forKey: "username")! as? String
                    
                    if username != "" && userid != 0 {
                        let mobileNo = result.value(forKey: "username")! as! String
                        
                        let url = HttpServer.SetDeviceTokenURL + "?account=" + mobileNo + "&DeviceToken=" + deviceTokenString
                        //print("url: \(url)")
                        
                        
                        Alamofire.request(url).responseJSON(completionHandler: { response in
                            if response.result.isSuccess {
                                do {
                                    let json: JSON = try! JSON(data: response.data!)
                                    print("json: \(json)")

                                    if json["StatusCode"] == 1 {
                                        print("更新Token成功")
                                    }
                                    else {
                                        print("更新Token失敗")
                                    }
                                } catch {
                                    print("error: \(String(describing: response.error))")
                                }
                            }
                            else {
                                print("error: \(String(describing: response.error))")
                            }
                        })
                    }
                }
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "qkee")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        /*
        // 將Data轉成String
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("deviceTokenString: \(deviceTokenString)")

        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().subscribe(toTopic: "/topics/all")
        Messaging.messaging().subscribe(toTopic: "/topics/ios")
        
        let myEntityName = "UserInfo"
        let myContext =
            (UIApplication.shared.delegate as! AppDelegate)
                .persistentContainer.viewContext
        let coreDataConnect = CoreDataConnect(context: myContext)
        
        // select
        let selectResult = coreDataConnect.retrieve(
            myEntityName, predicate: nil, sort: nil, limit: nil)
        
        if let results = selectResult {
            for result in results {
                
                print("userid: \(result.value(forKey: "userid")!),username: \(result.value(forKey: "username")!)")
                let userid = result.value(forKey: "userid")! as? Int
                let username = result.value(forKey: "username")! as? String
                
                if username != "" && userid != 0 {
                    let mobileNo = result.value(forKey: "username")! as! String
                    
                    let url = HttpServer.SetDeviceTokenURL + "?account=" + mobileNo + "&DeviceToken=" + deviceTokenString
                    //print("url: \(url)")
                    
                    
                    Alamofire.request(url).responseJSON(completionHandler: { response in
                        if response.result.isSuccess {
                            do {
                                let json: JSON = try! JSON(data: response.data!)
                                print("json: \(json)")
                            } catch {
                                print("error: \(String(describing: response.error))")
                            }
                        }
                        else {
                            print("error: \(String(describing: response.error))")
                        }
                    })
                }
            }
        }*/
    }
    
    // The callback to handle data message received via FCM for devices running iOS 10 or above.
    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
        print("Message:\(remoteMessage.appData)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print ("Eror: \(error.localizedDescription)")
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        Messaging.messaging().subscribe(toTopic: "/topics/ios")
    }
    
    //MARK: FCM Token Refreshed
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        // FCM token updated, update it on Backend Server

    
        print("FCM (Firebase Cloud Messaging) registration token: \(fcmToken)")
    }


    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("remoteMessage: \(remoteMessage)")
    }
    
    //Called when a notification is delivered to a foreground app.
    @available(iOS 10.0, *)
    
    // MARK: APP開啟狀況下的推播處理func
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification:   UNNotification, withCompletionHandler completionHandler: @escaping    (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
        // 印出後台送出的推播訊息(JSON 格式)
        let userInfo = notification.request.content.userInfo //推播訊息
        NotificationCenter.default.post(name: Notification.Name("OPEN"), object: nil, userInfo: userInfo)
        
        //print("開啟userInfo: \(userInfo)")
    
    }
    
    // MARK: APP背景或未啟動狀況下的推播處理func
    //Called to let your app know which action was selected by the user for a given notification.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response:    UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //print("User Info = \(response.notification.request.content.userInfo)")

        completionHandler()
    
        // 印出後台送出的推播訊息(JSON 格式)
        let userInfo = response.notification.request.content.userInfo //推播訊息
        //print("背景userInfo: \(userInfo)")
        
        var urlStr: String!
        if ((userInfo["url"]) != nil) {
            if userInfo["url"] as? String != "" {
                urlStr = userInfo["url"]! as? String
            }
            else {
                if ((userInfo["aid"]) != nil) {
                    let aid = userInfo["aid"]!
                    urlStr = HttpServer.ActivityURL + "?aid=\(aid)"
                }
            }
        }
        else {
            if ((userInfo["aid"]) != nil) {
                let aid = userInfo["aid"]!
                urlStr = HttpServer.ActivityURL + "?aid=\(aid)"
            }
        }
        
        if urlStr != nil {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let presentViewController = storyBoard.instantiateViewController(withIdentifier: "WebView") as! WebViewController

            presentViewController.urlStr = urlStr //pass userInfo data to viewController
            
            self.window?.rootViewController!.present(presentViewController, animated: true, completion: nil)
        }

        completionHandler()
    }
}
