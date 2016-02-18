//
//  ImageGalleryStoryInteractorTests.swift
//  QBRTCDemo
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

class ImageGalleryStoryInteractorTests: XCTestCase {

	var interactor: ImageGalleryStoryInteractor!
	var mockOutput: MockPresenter!
	
    override func setUp() {
        super.setUp()
		self.interactor = ImageGalleryStoryInteractor()
		self.mockOutput = MockPresenter()
		self.interactor.output = mockOutput
    }
	
	func testNotificatesAboutStartingSynchronizationImages() {
		// given
		
		// when
		self.interactor.startSynchronizationImages()

		// then
		XCTAssertTrue(self.mockOutput.didStartSynchronizationImagesGotCalled)
	}

    class MockPresenter: ImageGalleryStoryInteractorOutput {
		var didStartSynchronizationImagesGotCalled = false
		
		func didStartSynchronizationImages() {
			didStartSynchronizationImagesGotCalled = true
		}
    }
}
