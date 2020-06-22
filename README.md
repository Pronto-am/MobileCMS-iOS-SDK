# Pronto iOS SDK

<p align="center"><img src="Assets/logo.png" height="150" width="auto" />
<br>
 <i>The official Pronto iOS SDK</i>
<br><br>
<a href="https://cocoapods.org/pods/ProntoSDK"><img src="https://img.shields.io/cocoapods/p/ProntoSDK.svg?style=flat"></a>
<img src="https://img.shields.io/badge/swift-v5.1-f97a33.svg?longCache=true&style=flat">
<a href="https://cocoapods.org/pods/ProntoSDK"><img src="https://img.shields.io/cocoapods/v/ProntoSDK.svg?style=flat"></a> 
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
<a href="https://github.com/JamitLabs/Accio"><img src="https://img.shields.io/badge/Accio-supported-0A7CF5.svg?style=flat"></a>
<a href="LICENSE"><img src="https://img.shields.io/github/license/pronto-am/mobilecms-ios-sdk.svg?style=flat"></a>
<a href="https://htmlpreview.github.io/?https://github.com/Pronto-am/MobileCMS-iOS-SDK/blob/master/documentation/index.html"><img src="documentation/badge.svg"></a>
<a href="https://codecov.io/gh/pronto-am/MobileCMS-iOS-SDK"><img src="https://img.shields.io/codecov/c/github/Pronto-am/MobileCMS-iOS-SDK.svg?style=flat"></a>
<a href="https://travis-ci.org/Pronto-am/MobileCMS-iOS-SDK"><img src="https://img.shields.io/travis/Pronto-am/MobileCMS-iOS-SDK/master.svg?style=flat"></a>
<a href="https://beerpay.io/Pronto-am/MobileBundle"><img src="https://img.shields.io/beerpay/Pronto-am/MobileBundle.svg?style=flat"/></a>
</p>


----------

<p align="center">
 <b><a href="https://pronto-am.slack.com/messages/general"> <img src="Assets/slack-icon.png" width="16" /> Join our slack channel</a></b> &nbsp; <span style="color: #ccc">|</span> &nbsp; <b><img src="Assets/logo-beerpay.svg" width="16"> <a href="https://beerpay.io/Pronto-am/MobileBundle">Support us on Beerpay</a></b>
</p>

----------


## Installation

### Cococapods

Add the following to your Podfile:

```ruby
pod 'ProntoSDK'
```

**Available sub-specs:**

- `ProntoSDK/Authentication`
- `ProntoSDK/Notifications`
- `ProntoSDK/Collections`
- `ProntoSDK/AppUpdateCheck`
- `ProntoSDK/Localization`
- `ProntoSDK/RemoteConfig`

And run:

```shell
pod install
```

### Carthage

Add the following to your Cartfile:

```ruby
github "Pronto-am/MobileCMS-iOS-SDK"
```

And run:

```shell
carthage update
```

### SwiftPM

Add the following dependency to your Package.swift:

```swift
 .package(url: "https://github.com/Pronto-am/MobileCMS-iOS-SDK", .upToNextMajor(from: "2.0.0"))
```

### Accio

Add the following dependency to your Package.swift:

```swift
 .package(url: "https://github.com/Pronto-am/MobileCMS-iOS-SDK", .upToNextMajor(from: "2.0.0"))
```

And run:

```shell
accio install
```

## Development

Open `ProntoSDK.xcodeproj` end start development.

## Implementation

### Core

In `AppDelegate.swift`:

```swift
import ProntoSDK

func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    let config = ProntoConfig()
    
    // Setup the API client credentials
    config.clientID = <#CLIENT_ID#>
    config.clientSecret = <#CLIENT_SECRET#>
    config.encryptionKey = <#ENCRYPTION_KEY#>    
    config.domain = "mypronto.site.com"
    config.firebaseDomain = "myprontoproject.firebaseio.com"
    
    // Activate each plugin your project uses
    config.plugins = [ .notifications, .authentication, .collections, .localization, .updateChecker ]
    
    // Disable logging for non-debug builds
    #if DEBUG
        config.logger = Logger() // Should conform to `Cobalt.Logger` protocol
    #endif
    
    ProntoSDK.configure(config)
    
    // Do the rest of the implementation
    
    return true
```

### Notifications plugin

 → 📯  [Read notifications documentation](docs/NOTIFICATIONS.md)

### Authentication plugin

 → 🔐 [Read authentication documentation](docs/AUTHENTICATION.md)

### Collections plugin

 → 🗂 [Read collections documentation](docs/COLLECTIONS.md)

### Update checker plugin

 → 🌟 [Read update checker documentation](docs/UPDATECHECKER.md)

### Localization

 → 🇪🇺 [Read localization documentation](docs/LOCALIZATION.md)

### Remote config

 → ⚙️ [Read remote config documentation](docs/REMOTE-CONFIG.md)

## RxSwift

Almost every asynchronous function ProntoSDK uses `RxSwift` internally:

```swift
import RxSwift
import RxCocoa

let single = ProntoCollection<Location>().list() // = Single<[Location]>
single.subscribe(onSuccess: { locations in 
    // ...
}, onError: { error in 
    print("Error fetching locations: \(error)")
}).disposed(by: disposeBag)
```

## References
- [iOS SDK reference](https://htmlpreview.github.io/?https://github.com/Pronto-am/MobileCMS-iOS-SDK/blob/master/documentation/index.html) 🔗
