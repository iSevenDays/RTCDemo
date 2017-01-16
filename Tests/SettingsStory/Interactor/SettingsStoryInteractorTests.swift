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
	
	let settings: [SettingModel] = [SettingModel(label: "lbl", type: .switcher(enabled: true))]
	
    override func setUp() {
        super.setUp()
		interactor = SettingsStoryInteractor()
		mockOutput = MockPresenter()
		interactor.output = mockOutput
		
		mockCacheService = FakeCacheService()
		mockSettingsStorage = MockSettingsStorage()
		mockSettingsStorage.cacheService = mockCacheService
		interactor.settingsStorage = mockSettingsStorage
    }
	
	func testNotifiesPresenterAboutSettings() {
		// given
		mockSettingsStorage.fullHDVideoQualityEnabled = true
		
		// when
		interactor.requestSettings()
		
		// then
		XCTAssertTrue(mockOutput.didReceiveSettingsGotCalled)
	}
	
	func testNotifiesPresenterAboutChangedSettings() {
		// when
		interactor.handleSettingModelSelected(settings[0])
		
		// then
		XCTAssertTrue(mockOutput.didReceiveSettingsGotCalled)
	}

    class MockPresenter: SettingsStoryInteractorOutput {
		var didReceiveSettingsGotCalled = false
		
		func didReceiveSettings(settings: [SettingModel]) {
			didReceiveSettingsGotCalled = true
		}
    }
	
	class MockSettingsStorage: SettingsStorage {
		
	}
}
