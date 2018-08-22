# Authentication

## Logging in
```swift
let authentication = ProntoAuthentication()

authentication.login(email: "bas@e-sites.nl", password: "password").then { user in
    print("Logged in user: \(user)")
}.catch { error in 
	 print("Error logging in: \(error)")
}
```

To get the current user use:

```swift
let authentication = ProntoAuthentication()

if let currentUser = authentication.currentUser {
    // ... use currentUser
}
```

## Registration

```swift
let authentication = ProntoAuthentication()

let user = User()
user.email = "bas@e-sites.nl"
user.firstName = "Bas"
user.lastName = "van Kuijck"
user.extraData = [
    "gender": "male"
]

authentication.register(user: user, password: "password").then { user in
    print("Registered user: \(user)")
}.catch { error in
    print("Error registering: \(error)")
}
```

## Update

```swift
let authentication = ProntoAuthentication()
let user = ... // Get the locally stored user

authentication..user.update(user).then { user in
    print("Updated user: \(user)")
}.catch { error in 
    print("Error updating user: \(error)")
}
```

Read [online documentation](https://pronto.am/apidoc/index.html) for more information about API calls.