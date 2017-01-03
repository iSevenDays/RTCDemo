//
//  VideoCallStoryConfiguratorTests.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
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

class VideoCallStoryModuleConfiguratorTests: XCTestCase {

    func testConfigureModuleForViewController() {

        //given
        let viewController = VideoCallStoryViewControllerMock()
        let configurator = VideoCallStoryModuleConfigurator()

        //when
        configurator.configureModuleForViewInput(viewController)

        //then
        XCTAssertNotNil(viewController.output, "VideoCallStoryViewController is nil after configuration")
        XCTAssertTrue(viewController.output is VideoCallStoryPresenter, "output is not VideoCallStoryPresenter")
		XCTAssertNotNil(viewController.alertControl, "alertControl in VideoCallStoryViewController is nil after configuration")
		
        let presenter: VideoCallStoryPresenter = viewController.output as! VideoCallStoryPresenter
        XCTAssertNotNil(presenter.view, "view in VideoCallStoryPresenter is nil after configuration")
        XCTAssertNotNil(presenter.router, "router in VideoCallStoryPresenter is nil after configuration")
        XCTAssertTrue(presenter.router is VideoCallStoryRouter, "router is not VideoCallStoryRouter")

        let interactor: VideoCallStoryInteractor = presenter.interactor as! VideoCallStoryInteractor
        XCTAssertNotNil(interactor.output, "output in VideoCallStoryInteractor is nil after configuration")
		XCTAssertNotNil(interactor.callService, "callService in VideoCallStoryInteractor is nil after configuration")
		XCTAssertNotNil(interactor.pushService, "pushService in VideoCallStoryInteractor is nil after configuration")
    }

    class VideoCallStoryViewControllerMock: VideoCallStoryViewController {

    }
}
