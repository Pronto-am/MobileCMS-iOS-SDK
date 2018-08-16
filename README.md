# Pronto iOS SDK

<p align="center"><img src="Assets/logo.png" height="150" />
<br>
 <i>The official Pronto iOS SDK</i>
<br><br>
<img src="https://img.shields.io/badge/platform-ios-lightgrey.svg">
<a href="LICENSE"><img src="https://img.shields.io/github/license/pronto-am/mobilecms-ios-sdk.svg"></a>
<a href="https://htmlpreview.github.io/?https://github.com/Pronto-am/MobileCMS-iOS-SDK/blob/master/documentation/index.html"><img src="documentation/badge.svg"></a>
<a href="https://codecov.io/gh/pronto-am/MobileCMS-iOS-SDK"><img src="https://codecov.io/gh/pronto-am/MobileCMS-iOS-SDK/branch/master/graph/badge.svg"></a>
<a href="https://travis-ci.org/Pronto-am/MobileCMS-iOS-SDK"><img src="https://travis-ci.org/Pronto-am/MobileCMS-iOS-SDK.svg?branch=master"></a>
</p>

----------

<p align="center">
 <b><a href="https://pronto-am.slack.com/messages/general"><img src="Assets/slack-icon.png" width="16" /> Join our slack channel!</a></b>
</p>

----------


## Installation

### Cococapods

Add the following to your Podfile:

```ruby
pod 'ProntoSDK', :git => 'https://github.com/Pronto-am/MobileCMS-iOS-SDK.git'
```

**Available sub-specs:**

- `ProntoSDK/Authentication`
- `ProntoSDK/Notifications`
- `ProntoSDK/Collections`

And run:

```shell
pod install
```

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
    config.plugins = [ .notifications, .authentication, .collections ]
    
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

## Promises

Almost every asynchronous function ProntoSDK uses `Promises` internally:

```swift
let collection = ProntoCollection<Location>()
collection.list().then { result in
    // ...
}.catch { error in 
    print("Error fetching locations: \(error)")
}
```

If you want to convert it to your own handler [read the promises guide](docs/PROMISES.md).

## References
- [iOS SDK reference](https://htmlpreview.github.io/?https://github.com/Pronto-am/MobileCMS-iOS-SDK/blob/master/documentation/index.html) 🔗
