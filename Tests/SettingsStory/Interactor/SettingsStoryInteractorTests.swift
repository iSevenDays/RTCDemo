//
//  SettingsStorySettingsStoryInteractorTests.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/01/2017.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

import XCTest

#if QBRTCDemo_s
	@testable
	import QBRTCDemo_s
#elseif QBRTCDemo
	@testable
	import QBRTCDemo
#endif

class SettingsStoryInteractorTests: XCTestCase {

	var interactor: SettingsStoryInteractor!
	var mockOutput: MockPresenter!
	var mockCacheService: FakeCacheService!
	var mockSettingsStorage: MockSettingsStorage!
	var callService: FakeCallSevice!
	
    override func setUp() {
        super.setUp()
		interactor = SettingsStoryInteractor()
		mockOutput = MockPresenter()
		interactor.output = mockOutput
		
		mockCacheService = FakeCacheService()
		mockSettingsStorage.cacheService = mockCacheService
		interactor.settingsStorage = mockSettingsStorage
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func callsOutputWhenRequestedFullHDVideoQuality() {
		// given
		mockSettingsStorage.fullHDVideoQualityEnabled = true
		
		// when
		interactor.requestFullHDVideoQualityStatus()
		
		// then
		XCTAssertTrue(mockOutput.didReceiveFullHDVideoQualityEnabledGotCalled)
	}

    class MockPresenter: SettingsStoryInteractorOutput {
		var didReceiveFullHDVideoQualityEnabledGotCalled = false
		
		func didReceiveFullHDVideoQualityEnabled(enabled: Bool) {
			didReceiveFullHDVideoQualityEnabledGotCalled = true
		}
    }
	
	class MockSettingsStorage: SettingsStorage {
		
	}
}
