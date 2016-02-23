def available_pods
	pod 'ViperMcFlurry', '~> 1.2'
	pod 'Typhoon', '~> 3.3'
	pod 'RamblerTyphoonUtils/AssemblyCollector', '1.2.0'
end


target :QBRTCDemo_s, :exclusive => true do
	available_pods
end

target :QBRTCDemo, :exclusive => true do
	available_pods
end

target :QBRTCDemoTests, :exclusive => true do
	pod 'OCHamcrest', '~> 5.0'
	pod 'OCMock', '~> 3.2'
	pod 'RamblerTyphoonUtils/AssemblyTesting', '1.2.0'
end