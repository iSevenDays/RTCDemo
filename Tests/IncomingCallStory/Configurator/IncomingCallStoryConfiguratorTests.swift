//
//  IncomingCallStoryConfiguratorTests.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import XCTest

#if QBRTCDemo_s
	@testable
	import QBRTCDemo_s
#elseif QBRTCDemo
	@testable
	import QBRTCDemo
#endif

class IncomingCallStoryModuleConfiguratorTests: XCTestCase {

    func testConfigureModuleForViewController() {

        //given
        let viewController = IncomingCallStoryViewControllerMock()
        let configurator = IncomingCallStoryModuleConfigurator()

        //when
        configurator.configureModuleForViewInput(viewController)

        //then
        XCTAssertNotNil(viewController.output, "IncomingCallStoryViewController is nil after configuration")
        XCTAssertTrue(viewController.output is IncomingCallStoryPresenter, "output is not IncomingCallStoryPresenter")

        let presenter: IncomingCallStoryPresenter = viewController.output as! IncomingCallStoryPresenter
        XCTAssertNotNil(presenter.view, "view in IncomingCallStoryPresenter is nil after configuration")
        XCTAssertNotNil(presenter.router, "router in IncomingCallStoryPresenter is nil after configuration")
        XCTAssertTrue(presenter.router is IncomingCallStoryRouter, "router is not IncomingCallStoryRouter")
		XCTAssertNotNil((presenter.router as! IncomingCallStoryRouter).transitionHandler, "router transitionHandler is nil after configuration")

        let interactor: IncomingCallStoryInteractor = presenter.interactor as! IncomingCallStoryInteractor
        XCTAssertNotNil(interactor.output, "output in IncomingCallStoryInteractor is nil after configuration")
		XCTAssertNotNil(interactor.callService, "callService in IncomingCallStoryInteractor is nil after configuration")
    }

    class IncomingCallStoryViewControllerMock: IncomingCallStoryViewController {

        var setupInitialStateDidCall = false

        override func setupInitialState() {
            setupInitialStateDidCall = true
        }
    }
}
