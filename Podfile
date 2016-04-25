source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
inhibit_all_warnings!
use_frameworks!

target 'inMacChat' do
    pod 'Alamofire'
    pod 'SwiftyJSON'
    pod 'SnapKit'
    pod 'SCLAlertView'
    pod 'Instructions'
    pod 'SwiftSpinner'
    pod 'MMNumberKeyboard'
    pod 'KeychainAccess'
    pod 'EZSwiftExtensions'
    pod 'Haneke'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
        end
    end
end
