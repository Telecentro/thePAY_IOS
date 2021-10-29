# Uncomment the next line to define a global platform for your project
platform :ios, '11.4'

# [Xcodeproj] Generated duplicate UUIDs 제거
install!'cocoapods',:deterministic_uuids=>false

# CocoaPods 경고 제거
# inhibit_all_warnings!

# 타깃 워닝 제거
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
# 타깃 워닝 제거 (END)

def common_pods
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
  
  # Pods for thepay
  
  # HTTP
  pod 'Alamofire', '~> 5.1'
  pod 'SDWebImage', '~> 5.0'
  pod 'Kingfisher', '~> 5.0'
  
  
  #firebase
  pod 'Firebase/Core'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Firebase/DynamicLinks'
  
  #Google
  pod 'Firebase/Auth'
  pod 'GoogleSignIn'
  
  #facebook
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  #  pod 'FBSDKCoreKit', '~> 4.38.0'
  #  pod 'FBSDKLoginKit', '~> 4.38.0'
  
  #UTILS
  pod 'TPKeyboardAvoiding'
  pod 'PPSSignatureView'
  pod 'TOCropViewController'
  pod 'BSImagePicker', '~> 3.1'
  #  pod 'APAddressBook'
  #  pod 'PKHUD', '~> 5.0'
  #  pod "Device", '~> 3.2.1'
  
  # ReactiveX
  pod 'RxSwift', '6.2.0'
  pod 'RxCocoa', '6.2.0'
  
  pod 'SnapKit'
  pod 'SPMenu'
  
end

def common_pods_test
  #firebase
  pod 'Firebase/Core'
end

target 'thepay' do
  common_pods
end

target 'Test' do
  common_pods_test
end
