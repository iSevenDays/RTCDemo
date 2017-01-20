//
//  SettingsStorySettingsStoryViewTests.swift
//  RTCDemo
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

class SettingsStoryViewTests: XCTestCase {

	var controller: SettingsStoryViewController!
	var mockOutput: MockViewControllerOutput!
	
	let emptySender = UIResponder()
	let settingSection = SettingsSection(name: "name", settings: [SettingModel(type: .subtitle(label: "lbl", subLabel: nil, selected: false))])
	
	override func setUp() {
		super.setUp()
		controller = UIStoryboard(name: "SettingsStory", bundle: nil).instantiateViewControllerWithIdentifier(String(SettingsStoryViewController.self)) as! SettingsStoryViewController
		
		mockOutput = MockViewControllerOutput()
		controller.output = mockOutput
	}
	
	func testViewDidLoadTriggersViewIsReadyAction() {
		// when
		controller.viewDidLoad()
		
		// then
		XCTAssertTrue(mockOutput.viewIsReadyGotCalled)
	}
	
	func testFullHDVideoQualityButtonTriggersAction() {
		// given
		controller.settingsSections = [settingSection]
		
		// when
		controller.tableView.reloadData()
		controller.tableView(controller.tableView, didSelectRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
		
		// then
		XCTAssertTrue(mockOutput.didSelectSettingModelGotCalled)
		XCTAssertEqual(mockOutput.settingModel, settingSection.settings.first)
	}
	
	@objc class MockViewControllerOutput : NSObject, SettingsStoryViewOutput {
		var viewIsReadyGotCalled = false
		
		var didSelectSettingModelGotCalled = false
		var settingModel: SettingModel?
		
		func viewIsReady() {
			viewIsReadyGotCalled = true
		}
		func didSelectSettingModel(settingModel: SettingModel) {
			didSelectSettingModelGotCalled = true
			self.settingModel = settingModel
			
		}
	}

}
