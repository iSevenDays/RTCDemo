//
//  ChatUsersStoryConfiguratorTests.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
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

class ChatUsersStoryModuleConfiguratorTests: XCTestCase {

    func testConfigureModuleForViewController() {
		//given
        let viewController = ChatUsersStoryViewControllerMock()
        let configurator = ChatUsersStoryModuleConfigurator()

        //when
        configurator.configureModuleForViewInput(viewController)

        //then
        XCTAssertNotNil(viewController.output, "ChatUsersStoryViewController is nil after configuration")
        XCTAssertTrue(viewController.output is ChatUsersStoryPresenter, "output is not ChatUsersStoryPresenter")
		
        let presenter: ChatUsersStoryPresenter = viewController.output as! ChatUsersStoryPresenter
        XCTAssertNotNil(presenter.view, "view in ChatUsersStoryPresenter is nil after configuration")
        XCTAssertNotNil(presenter.router, "router in ChatUsersStoryPresenter is nil after configuration")
        XCTAssertTrue(presenter.router is ChatUsersStoryRouter, "router is not ChatUsersStoryRouter")
		XCTAssertNotNil((presenter.router as! ChatUsersStoryRouter).transitionHandler, "transition handler for ChatUsersStoryRouter is nil after configuration, transitionHandler must be ChatUsersStoryViewController")

        let interactor: ChatUsersStoryInteractor = presenter.interactor as! ChatUsersStoryInteractor
        XCTAssertNotNil(interactor.output, "output in ChatUsersStoryInteractor is nil after configuration")
		XCTAssertNotNil(interactor.cacheService, "cachedService in ChatUsersStoryInteractor is nil after configuration")
		
//		let callService = ServicesProvider.currentProvider.callService
		
//		guard let delegates = callService.observers else {
//			XCTFail("callService delegates must contain interactor ChatUsersStoryInteractor after configuration")
//			return
//		}
//		
//		let interactorIsInDelegatesList = delegates.contains({$0 === interactor})
//		
//		XCTAssertTrue(interactorIsInDelegatesList, "interactor ChatUsersStoryInteractor is not in delegates list of CallService after configuration")
    }

    class ChatUsersStoryViewControllerMock: ChatUsersStoryViewController {

        override func setupInitialState() {
			
        }
    }
}
