platform :ios, '8.1'

inhibit_all_warnings!
use_frameworks!

target 'Mattermost' do 
  pod 'DateTools'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'RestKit'
  pod 'MRProgress'
  pod 'SwiftyJSON'
  pod 'SnapKit', '~> 3.0.2'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0.1'
    end
  end
end
