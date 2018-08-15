# Notifications

in `AppDelegate.swift`:

```swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ProntoNotificationsDelegate {
    fileprivate lazy var prontoNotifications = ProntoNotifications()
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // ProntoSDK core configuration    
        
        prontoNotifications.delegate = self        
        
        // The rest of your configuration
    
        return true
    }
	
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        prontoNotifications.didRegisterForRemoteNotifications(deviceToken: deviceToken)
    }
	
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        prontoNotifications.didFailToRegisterForRemoteNotifications(with: error)
    }
	
    func application(_ application: UIApplication,
                 didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        prontoNotifications.handleNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }

    // Handle the push notification when the app is in the foreground
    func prontoNotifications(_ prontoNotifications: ProntoNotifications,
                             didReceivePushNotification pushNotification: PushNotification) {

    }
}
```

To register for push notifications:

```swift
#if DEBUG
    let sandbox = true
#else
    let sandbox = false
#endif

prontoNotifications.registerForRemoteNotifications(sandbox: sandbox) { error in
    // If `error` is nil -> succesful
}
```

Read [online documentation](https://pronto.am/apidoc/index.html) for more information about API calls.