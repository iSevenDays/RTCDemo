platform :ios, "8.0"

def available_pods
	pod 'ViperMcFlurry', '~> 1.5.2'
end


target :QBRTCDemo_s do
	available_pods
end

target :QBRTCDemo do
	available_pods
end

def tests_pods
	inherit! :search_paths
end

target :QBRTCDemoTests do
	tests_pods
end

target :QBRTCDemo_sTests do
	tests_pods
end
