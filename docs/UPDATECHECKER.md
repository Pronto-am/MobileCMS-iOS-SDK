# Update checker

This plugin automatically checks if there are any app updates and allows the user to present the user with an option or force him/her to update the app.

## Implementation

in `AppDelegate.swift`:

```swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ProntoAppUpdateCheckDelegate {
    fileprivate lazy var updateChecker = ProntoAppUpdateCheck()
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // ProntoSDK core configuration    
        
        updateChecker.delegate = self
        updateChecker.shouldCheckOnAppLaunch = true
        
        // The rest of your configuration
    
        return true
    }	
    
    /// Will automatically be called when the app's state turns active
    func prontoAppUpdateCheck(_ updateCheck: ProntoAppUpdateCheck, newVersion: AppVersion) {
        let alertController = UIAlertController(title: "New version available", 
                                                message: "A new version (\(newVersion.version)) is available",
                                                preferredStyle: .alert)
                                                
        alertController.addAction(UIAlertAction(title: "Install", style: .default) { _ in
            UIApplication.shared.open(newVersion.url, options: [:], completionHandler: nil)
            exit(0)
        })
        if !newVersion.isRequired {
            alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        }
        
        window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}
```