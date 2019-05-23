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

let dutchLocale = Locale(identifier: "nl_NL")
localization.get(for: "welcome_user", locale: dutchLocale) // -> "Welkom"
```

## Dupnium

Pronto Localization can pretty easily be used in combination with [Dupnium](https://github.com/e-sites/Dupnium):

And add this to your Podfile along with the ProntoSDK reference:

```ruby
pod 'Dupnium/UI'
```

### Implementation

```swift
import Dupnium
import ProntoSDK

class DupniumInstance: Dupnium {
    override public func string(_ key: String) -> String {
        // Instead of retrieving the localization from a `Localizable.strings` file,
        // it will get it from ProntoLocalization
        return ProntoLocalization.get(for: key, locale: locale)
    }
}

class LocalizedLabelInstance: Dupnium.LocalizedLabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dupnium = DupniumInstance.shared
    }
}

class LocalizedButtonInstance: Dupnium.LocalizedButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dupnium = DupniumInstance.shared
    }
}

```

### Usage

Now just set the text in interface builder's LocalizedLabelInstance to "welcome_user". And it's automatically translated to your locale.

```swift

typealias Dup = DupniumInstance.shared

Dup["welcome_user"] // <- "Welcome user"

```


## Command line interface

Download it here: [Scripts/importlocalization](../Scripts/importlocalization)

And create a folder in your project root named "Scripts" and save it there.

Then open the (ruby) script with your favourite text editor and change the following lines:

```ruby
CLIENT_ID         = "<#PRONTO_CLIENT_ID#>"
CLIENT_SECRET     = "<#PRONTO_CLIENT_SECRET#>"
PRONTO_HOST       = "<#PRONTO_HOST#>"
RESOURCES_PATH    = "../ProjectName/Resources/" # Resource relative path
```

The be able to execute it:

```
chmod +x Scripts/importlocalization
```

Then run:

```
Scripts/importlocalization
```

Your project should have a structure similar to this:

```
ProjectName/
|
|- fastlane/
|  |
|  |- metadata/
|  |  |- en-GB/
|  |  |  |- <metadata_files>
|  |  |  |- <metadata_files>
|  |  |
|  |  |- nl-NL/
|  |  |  |- <metadata_files>
|  |  |  |- <metadata_files>
|
|- Resources/
|  |
|  |- en.lproj/ 
|  |  |- Localizable.strings
|  |  |- InfoPlist.strings
|  |
|  |- nl.lproj/ 
|  |  |- Localizable.strings
|  |  |- InfoPlist.strings
```

This CLI script will automatically generate the following files per locale:

- `Localizable.strings`
- `InfoPlist.strings`
- Fastlane metadata files