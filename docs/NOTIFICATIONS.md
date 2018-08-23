# Notifications

## Implementation

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

## Device registration

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

To unregister:

```swift
guard let device = Device.current else {
	return
}

ProntoAPIClient.default.notifications.unregister(device: device).then { 
   // ...
}
```

## Segments

To get all the available segments:

```swift
guard let device = Device.current else {
	return
}

ProntoAPIClient.default.notifications.segments(for: device).then { segments in
   // `segments`: [Segment]
}
```

To subscribe to a segment:

```swift
guard let device = Device.current else {
	return
}

let segment: Segment = // Get a specific segment
segment.isSubscribed = true

ProntoAPIClient.default.notifications.subscribe(segments: [ segment ], device: device).then { 
   // ...
}
```

-------

Read [online documentation](https://pronto.am/apidoc/index.html) for more information about API calls.