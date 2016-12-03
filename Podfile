def available_pods
	pod 'ViperMcFlurry', '~> 1.5.2'
	pod 'Typhoon', '~> 3.4.5'
	pod 'RamblerTyphoonUtils/AssemblyCollector', '1.5.0'
	pod 'CocoaLumberjack'
end


target :QBRTCDemo_s do
	available_pods
end

target :QBRTCDemo do
	available_pods
end

def tests_pods
	pod 'OCMock', '~> 3.3.1'
end

target :QBRTCDemoTests do
	tests_pods
end

target :QBRTCDemo_sTests do
	tests_pods
end
