//
//  AppDelegate.swift
//  thepay
//
//  Created by xeozin on 2020/06/26.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCrashlytics
import FirebaseDynamicLinks
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 파이어 베이스 설정
        FirebaseApp.configure()
        
        // FACEBOOK 2020.10.20
        ApplicationDelegate.shared.application( application, didFinishLaunchingWithOptions: launchOptions )
        
        if let myPinNumber = UserDefaultsManager.shared.loadMyPinNumber() {
            if myPinNumber.count > 0 {
                let lang = UserDefaultsManager.shared.loadNationCode()
                Crashlytics.crashlytics().setUserID("iOS_\(lang)_\(myPinNumber)")
            }
        }
        
        // 화면 꺼짐 방지
        UIApplication.shared.isIdleTimerDisabled = true
        
        // PUSH 서비스 설정
        setupPushService(application)
        
        // Launched from Push notification
        if let options = launchOptions,
            let userInfo = options[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any] {
            
            let aps = userInfo["aps"] as? [String: Any]
            NSLog("\n Custom: \(String(describing: aps))")
            App.shared.hasPushInfo = true
            App.shared.userInfo = userInfo
            application.applicationIconBadgeNumber = 0
        }
        
//        UserDefaultsManager.shared.saveIsNetworkAccess = true
        return true
    }
    
//    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        guard let rootViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController) else { return .portrait }
//
//        if rootViewController is SignViewController {
//            return .all
//        } else {
//            return .portrait
//        }
//    }
//
//    private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
//        guard rootViewController != nil else { return nil }
//
//        guard !(rootViewController.isKind(of: (UITabBarController).self)) else{
//            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
//        }
//        guard !(rootViewController.isKind(of:(UINavigationController).self)) else{
//            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
//        }
//        guard !(rootViewController.presentedViewController != nil) else {
//            return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
//        }
//        return rootViewController
//    }
    
    private func setupPushService(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // 디바이스 토큰
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("Apple registration token: \(deviceToken) \(deviceTokenString)")
        if let loadToken = UserDefaultsManager.shared.loadAPNSToken() {
            if loadToken != deviceTokenString {
                updateToken(token: deviceTokenString)
            }
        } else {
            updateToken(token: deviceTokenString)
        }
    }
    
    func updateToken(token: String) {
        UserDefaultsManager.shared.saveAPNSToken(value: token)
        
        let req = PushRestoreRequest(token: token)
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response:Swift.Result<PushRestoreResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
            }
            
        }
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        push(application: application, userInfo: userInfo)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
      let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
        print("aaa")
      }

      return handled
    }
    
    func externalURLScheme(i:Int) -> String? {
        guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [AnyObject],
            let urlTypeDictionary = urlTypes[i] as? [String: AnyObject],
            let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [AnyObject],
            let externalURLScheme = urlSchemes.first as? String else { return nil }

        return externalURLScheme
    }
    
    /* 신형 */
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            if (dynamicLink.url != nil) {
                UserDefaultsManager.shared.saveDynamicLink(value: dynamicLink.url?.absoluteString)
            }
        }
        
        if let facebook = externalURLScheme(i: 0) {
            if facebook == url.scheme {
                return FBSDKCoreKit.ApplicationDelegate.shared.application(app, open: url, options: options)
            }
        }
        
        if let google = externalURLScheme(i: 1) {
            if google == url.scheme {
                return GIDSignIn.sharedInstance.handle(url)
            }
        }
        
        App.shared.deeplink = url.absoluteString
        if App.shared.pre != nil {
            NotificationCenter.default.post(name: ThePayNotification.DeepLink.name, object: nil)
        }
        
        // FACEBOOK 2020.10.20
        ApplicationDelegate.shared.application( app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        
        return false
    }
    
    /* 구형 */
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            print("Handling a link through the openURL method!")
            self.handleIncomingDynamicLink(dynamicLink)
            return true
        }
        return false
    }
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        print("Your incoming link parameter is \(String(describing: dynamicLink.url))")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        push(application: UIApplication.shared, userInfo: userInfo)
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        let userInfo = notification.request.content.userInfo
        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            print ("Message Closed")
        }
        else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            
            // 여기서 위의 받았을 때 mainVC나 이동로직 이상하게 쓰면 UNUserNotificationCenterDelegate methods not being called 나옴
        }
        
        push(application: UIApplication.shared, userInfo: userInfo)
        completionHandler()
    }
    
    private func push(application: UIApplication, userInfo: [AnyHashable : Any]) {
        application.applicationIconBadgeNumber = 0
        
        if userInfo.keys.contains("gcm.message_id") {
            return
        } else {
            App.shared.userInfo = userInfo
        }
        
        App.shared.hasPushInfo = true
        NotificationCenter.default.post(name: ThePayNotification.Push.name, object: nil)
        NotificationCenter.default.post(name: ThePayNotification.Contact.name, object: nil)
    }
}

extension AppDelegate {
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: ThePayNotification.RequestRemains.name, object: nil)
    }
}
