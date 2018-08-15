source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

target 'ProntoSDK' do
  # e-sites/ios-suite
  pod 'Erbium'
  pod 'Cobalt'
  pod 'Einsteinium'

  # master
  pod 'SwiftyJSON'
  pod 'KeychainAccess'
  pod 'SwiftLint'
  pod 'CryptoSwift'
  pod 'Cache'
  pod 'EasyPeasy'
  pod 'PromisesSwift'
  pod 'RxSwift'

  target 'ProntoSDKTests' do
    inherit! :search_paths
    pod 'Nimble'
    pod 'URITemplate', :git => 'https://github.com/basvankuijck/URITemplate.swift.git'
    pod 'Mockingjay'

    # e-sites/ios-suite
    pod 'Lithium'
    pod 'Lithium/Cobalt'
  end
end
