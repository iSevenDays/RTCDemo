def available_pods
	pod 'ViperMcFlurry', '~> 1.2'
	pod 'Typhoon', '~> 3.4.5'
	pod 'RamblerTyphoonUtils/AssemblyCollector', '1.2.0'
	pod 'CocoaLumberjack'
end


target :QBRTCDemo_s, :exclusive => true do
	available_pods
end

target :QBRTCDemo, :exclusive => true do
	available_pods
end

def tests_pods
	pod 'OCHamcrest', '~> 5.0'
	pod 'OCMock', '~> 3.2'
	pod 'RamblerTyphoonUtils/AssemblyTesting', '1.2.0'
end

target :QBRTCDemoTests, :exclusive => true do
	tests_pods
end

target :QBRTCDemo_sTests, :exclusive => true do
	tests_pods
end