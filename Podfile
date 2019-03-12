source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/Artsy/Specs.git'

platform :ios, "10.0"
inhibit_all_warnings!
use_frameworks!

target 'QBRTCDemo' do
	pod 'ViperMcFlurry', '~> 1.5.2'
	pod 'GoogleWebRTC', '~> 1.1'
	pod 'KeychainSwift', '~> 13.0'

	target 'QBRTCDemoTests' do
		inherit! :search_paths
	end
end

target 'QBRTCDemo_s' do
	pod 'ViperMcFlurry', '~> 1.5.2'
	pod 'GoogleWebRTC', '~> 1.1'
	pod 'KeychainSwift', '~> 13.0'

	target 'QBRTCDemo_sTests' do
		inherit! :search_paths
	end
end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		puts target.name
	end
end
