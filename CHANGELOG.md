# ProntoSDK Changelog

## v4.0.0
- Updated Cobalt

## v3.0.0
- Replaced Promises with RxSwift / RxCocoa

## v2.8.4
- [RemoteConfig] public variables fixed

## v2.8.3
- [Authentication] Fixed a bug where the user would be automatically logged out

## v2.8.2
- [Collections] Add URL as mappable

## v2.8.1
- [Authentication] Throw ProntoError.invalidCredentials on invalid login

## v2.8.0
- Remote config plugin

## v2.7.1
- Fixed Mockingjay SwiftPM dependencies

## v2.7.0
- Xcode11 compatible / SwiftPM

## v2.6.2
- Use "pronto_logs" firebase realtime database table to write logs to.

## v2.6.1
- Localization fixes
- `Text.getString()` now returns `String?` instead of `String`

## v2.6.0
- Refactored Notifications and Authentication

## v2.5.0
- Added localization

## v2.4.1
- Changed build pipeline 

## v2.4.0
- Accio compatible

## v2.3.2
- [UpdateChecker] Force semantic versioning

## v2.3.1
- [Collections] Made `id`, `updateDate` and `createDate` not required
- [Core] Made `request(_:)` function in `ProntoAPIClient` public

## v2.3.0
- Added "Update Checker"

## v2.2.0
- Updated to Swift4.2 / Xcode 10

## v2.1.3
- Fixed a bug in push notifications registration.

## v2.1.2
- Refactored push notification registration. 

## v2.1.1
- Make `firstName` obligatory for user registration

## v2.1.0
- Store current user in `ProntoAuthentication`

## v2.0
- Implemented OAuth2

## v1.0
- Initial release