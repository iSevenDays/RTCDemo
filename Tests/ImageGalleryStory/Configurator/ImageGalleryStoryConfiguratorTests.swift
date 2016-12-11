//
//  ImageGalleryStoryConfiguratorTests.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/02/2016.
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

class ImageGalleryStoryModuleConfiguratorTests: XCTestCase {

    func testConfigureModuleForViewController() {

        //given
        let viewController = ImageGalleryStoryViewControllerMock()
        let configurator = ImageGalleryStoryModuleConfigurator()

        //when
        configurator.configureModuleForViewInput(viewController)

        //then
        XCTAssertNotNil(viewController.output, "ImageGalleryStoryViewController is nil after configuration")
        XCTAssertTrue(viewController.output is ImageGalleryStoryPresenter, "output is not ImageGalleryStoryPresenter")

        let presenter: ImageGalleryStoryPresenter = viewController.output as! ImageGalleryStoryPresenter
        XCTAssertNotNil(presenter.view, "view in ImageGalleryStoryPresenter is nil after configuration")
        XCTAssertNotNil(presenter.router, "router in ImageGalleryStoryPresenter is nil after configuration")
        XCTAssertTrue(presenter.router is ImageGalleryStoryRouter, "router is not ImageGalleryStoryRouter")

        let interactor: ImageGalleryStoryInteractor = presenter.interactor as! ImageGalleryStoryInteractor
        XCTAssertNotNil(interactor.output, "output in ImageGalleryStoryInteractor is nil after configuration")
		XCTAssertNotNil(interactor.imagesOutput, "imageOutput in ImageGalleryStoryInteractor is nil after configuration")
		XCTAssertNotNil(interactor.callService, "callService in ImageGalleryStoryInteractor is nil after configuration")
    }

    class ImageGalleryStoryViewControllerMock: ImageGalleryStoryViewController {

        var setupInitialStateDidCall = false

        override func setupInitialState() {
            setupInitialStateDidCall = true
        }
    }
}
