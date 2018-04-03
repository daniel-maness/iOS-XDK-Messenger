platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
target 'XDK Messenger' do

  pod 'LayerXDK/UI', '= 4.0.0'
  pod 'LayerKit', '= 4.0.0'
  pod 'SVProgressHUD'
  pod 'ClusterPrePermissions', '~> 0.1'
  pod 'LayerKitDiagnostics'

  target 'XDK MessengerTests' do
      inherit! :search_paths
      pod 'Expecta'
      pod 'OCMock'
      pod 'KIF'
      pod 'KIFViewControllerActions', git: 'https://github.com/blakewatters/KIFViewControllerActions.git'
      pod 'LYRCountDownLatch'
  end
end

# If we are building LayerKit from source then we need a post install hook to handle non-modular SQLite imports
unless ENV['LAYER_USE_CORE_SDK_LOCATION'].blank?
  post_install do |installer|
    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
      configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    end
  end
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
    end
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
        end
    end
end
