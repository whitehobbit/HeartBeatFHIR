# Uncomment this line to define a global platform for your project
platform :ios, '10.0'
use_frameworks!

target 'HeartBeatFHIR' do
  pod 'SwiftCharts', '~> 0.5'
  pod 'FHIR', :git => 'https://github.com/smart-on-fhir/Swift-FHIR.git'
  pod 'Alamofire', '~> 4.0'
  pod 'SwiftyJSON', '~> 3.1'
  pod 'SwiftyDropbox'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0.1'
        end
    end
end
