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
end


post_install do |installer|

  Dir.glob(installer.sandbox.target_support_files_root + "Pods-*/*.sh").each do |script|
    flag_name = File.basename(script, ".sh") + "-Installation-Flag"
    folder = "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
    file = File.join(folder, flag_name)
    content = File.read(script)
    content.gsub!(/set -e/, "set -e\nKG_FILE=\"#{file}\"\nif [ -f \"$KG_FILE\" ]; then exit 0; fi\nmkdir -p \"#{folder}\"\ntouch \"$KG_FILE\"")
    File.write(script, content)
  end
  
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
        config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
        config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
      config.build_settings['SWIFT_VERSION'] = '3.0.2'
    end
  end
end
