//
//  SettingsStorySettingsStoryPresenterTests.swift
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

class SettingsStoryPresenterTest: XCTestCase {

	var presenter: SettingsStoryPresenter!
	var mockInteractor: MockInteractor!
	var mockRouter: MockRouter!
	var mockView: MockViewController!
	
	let settings: [SettingModel] = [SettingModel(label: "lbl", type: .switcher(enabled: true))]
	
    override func setUp() {
        super.setUp()
		presenter = SettingsStoryPresenter()
		
		mockInteractor = MockInteractor()
		
		mockRouter = MockRouter()
		mockView = MockViewController()
		
		presenter.interactor = mockInteractor
		presenter.router = mockRouter
		presenter.view = mockView
    }
	
	// MARK: SettingsStoryViewOutput tests
	
	func testPresenterHandlesViewReadyEvent() {
		// when
		presenter.viewIsReady()
		
		// then
		XCTAssertTrue(mockView.setupInitialStateGotCalled)
		XCTAssertTrue(mockInteractor.requestSettingsGotCalled)
	}
	
	// MARK: SettingsStoryInteractorOutput tests
	func testPresenterNotifiesViewAboutReceivedSettings() {
		// when
		presenter.didReceiveSettings(settings)
		
		// then
		XCTAssertTrue(mockView.reloadSettingsGotCalled)
	}
	
	// MARK: - SettingsStoryViewOutput tests
	
	func testRequestsInteractorToSwitchFullHDVideoQualityState() {
		// when
		presenter.didSelectSettingModel(settings[0])
		
		// then
		XCTAssertTrue(mockInteractor.handleSettingModelSelectedGotCalled)
	}

    class MockInteractor: SettingsStoryInteractorInput {
		var handleSettingModelSelectedGotCalled = false
		var requestSettingsGotCalled = false
		
		func requestSettings() {
			requestSettingsGotCalled = true
		}
		
		func handleSettingModelSelected(settingModel: SettingModel) {
			handleSettingModelSelectedGotCalled = true
		}
    }

    class MockRouter: SettingsStoryRouterInput {

    }

    class MockViewController: SettingsStoryViewInput {
		var setupInitialStateGotCalled = false
		
		var reloadSettingsGotCalled = false
		
        func setupInitialState() {
			setupInitialStateGotCalled = true
        }
		
		func reloadSettings(settings: [SettingModel]) {
			reloadSettingsGotCalled = true
		}
    }
}
