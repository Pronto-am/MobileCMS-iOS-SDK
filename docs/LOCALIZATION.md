# Localization

This plugin uses the translations section in Pronto to retrieve localization at run time.

## Implementation

For your convenience make a custom singleton:

`Localization.swift`

```swift
import ProntoSDK

class Localization: ProntoLocalization {
    static let shared = Localization().setup()
    
    private func setup() -> Localization {
        setDefaults([
            "welcome_user": [ "nl": "Welkom", "en": "Welcome" ],
            "next": [ "nl": "Volgende", "en": "Next" ]
        ])
        return self
    }
}

```

### Reloading

To fetch the latest localization use:

```swift
Localization.shared.fetch().then { 
    // Successful
}.catch { error in 
    // Failure
}
```

### Using a translation

```swift
localization.get(for: "welcome_user") // -> "Welcome"

```