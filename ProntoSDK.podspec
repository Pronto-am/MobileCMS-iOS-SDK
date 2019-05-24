Pod::Spec.new do |s|
  s.name         = "ProntoSDK"
  s.version      = "2.5.0"
  s.author       = { "Bas van Kuijck" => "bas@e-sites.nl" }
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.homepage     = "http://www.e-sites.nl"
  s.summary      = "_THE_ Swift iOS Pronto SDK"
  s.source       = { :git => "https://github.com/Pronto-am/MobileCMS-iOS-SDK.git", :tag => "v#{s.version}" }
  s.source_files = "ProntoSDK/ProntoSDK.h"
  s.public_header_files  = "ProntoSDK/ProntoSDK.h"
  s.platform     = :ios, '10.0'
  s.requires_arc  = true
  s.default_subspec = 'Core'
  s.swift_versions = [ '4.2', '5.0' ]

  s.subspec 'Core' do |ss|
    ss.dependency 'SwiftyJSON'
    ss.dependency 'KeychainAccess'
    ss.dependency 'CryptoSwift'
    ss.dependency 'PromisesSwift'

    ss.dependency 'Cobalt'
    ss.dependency 'Einsteinium'

    ss.source_files = "ProntoSDK/Classes/Core/**/*.{h,m,swift}"
  end

  s.subspec 'Notifications' do |ss|
    ss.dependency 'ProntoSDK/Core'
    ss.dependency 'Erbium'
    ss.source_files = "ProntoSDK/Classes/Notifications/**/*.{h,m,swift}"
    ss.frameworks = 'UserNotifications', 'UIKit', 'WebKit'
  end

  s.subspec 'Authentication' do |ss|
    ss.dependency 'ProntoSDK/Core'
    ss.dependency 'RxSwift'
    ss.source_files = "ProntoSDK/Classes/Authentication/**/*.{h,m,swift}"
  end

  s.subspec 'Collections' do |ss|
    ss.dependency 'ProntoSDK/Core'
    ss.source_files = "ProntoSDK/Classes/Collections/**/*.{h,m,swift}"
    ss.frameworks = 'CoreLocation'
  end

  s.subspec 'AppUpdateCheck' do |ss|
    ss.dependency 'ProntoSDK/Core'
    ss.dependency 'Erbium'
    ss.source_files = "ProntoSDK/Classes/AppUpdateCheck/**/*.{h,m,swift}"
  end

  s.subspec 'Localization' do |ss|
    ss.dependency 'ProntoSDK/Core'
    ss.source_files = "ProntoSDK/Classes/Localization/**/*.{h,m,swift}"
  end

  # s.test_spec 'Tests' do |test_spec|
  #   test_spec.dependency 'ProntoSDK/Collections'
  #   test_spec.dependency 'ProntoSDK/Authentication'
  #   test_spec.dependency 'ProntoSDK/Notifications'
  #   test_spec.dependency 'Lithium'
  #   test_spec.dependency 'Lithium/Cobalt'
  #   test_spec.dependency 'Nimble'
  #   test_spec.dependency 'Mockingjay'


  #   test_spec.requires_app_host = false
  #   test_spec.source_files = 'ProntoSDKTests/**/*.{h,swift}'
  #   test_spec.resources = 'ProntoSDKTests/Mocking/*.json'
  # end

end
