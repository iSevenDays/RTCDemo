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
	
	let setting = SettingModel(type: .subtitle(label: "Medium", subLabel: nil, selected: false))
	
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
		// when
		interactor.requestSettings()
		
		// then
		XCTAssertTrue(mockOutput.didReceiveSettingsGotCalled)
	}
	
	func testNotifiesPresenterAboutChangedSettings() {
		// when
		interactor.handleSettingModelSelected(setting)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveSettingsGotCalled)
	}

    class MockPresenter: SettingsStoryInteractorOutput {
		var didReceiveSettingsGotCalled = false
		
		func didReceiveSettings(settings: [SettingsSection]) {
			didReceiveSettingsGotCalled = true
		}
    }
	
	class MockSettingsStorage: SettingsStorage {
		
	}
}
