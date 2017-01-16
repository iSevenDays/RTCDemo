//
//  SettingsStorySettingsStoryConfiguratorTests.swift
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

class SettingsStoryModuleConfiguratorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
	
    func testConfigureModuleForViewController() {

        //given
        let viewController = SettingsStoryViewControllerMock()
        let configurator = SettingsStoryModuleConfigurator()

        //when
        configurator.configureModuleForViewInput(viewController)

        //then
        XCTAssertNotNil(viewController.output, "SettingsStoryViewController is nil after configuration")
        XCTAssertTrue(viewController.output is SettingsStoryPresenter, "output is not SettingsStoryPresenter")

        let presenter: SettingsStoryPresenter = viewController.output as! SettingsStoryPresenter
        XCTAssertNotNil(presenter.view, "view in SettingsStoryPresenter is nil after configuration")
        XCTAssertNotNil(presenter.router, "router in SettingsStoryPresenter is nil after configuration")
        XCTAssertTrue(presenter.router is SettingsStoryRouter, "router is not SettingsStoryRouter")

        let interactor: SettingsStoryInteractor = presenter.interactor as! SettingsStoryInteractor
        XCTAssertNotNil(interactor.output, "output in SettingsStoryInteractor is nil after configuration")
		XCTAssertNotNil(interactor.settingsStorage, "settingsStorage in SettingsStoryInteractor is nil after configuration")
		XCTAssertNotNil(interactor.settingsStorage.cacheService, "cacheService in settingsStorage in SettingsStoryInteractor is nil after configuration")
    }

    class SettingsStoryViewControllerMock: SettingsStoryViewController {

        var setupInitialStateDidCall = false

        override func setupInitialState() {
            setupInitialStateDidCall = true
        }
    }
}
