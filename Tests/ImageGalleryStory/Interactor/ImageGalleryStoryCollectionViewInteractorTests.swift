//
//  ImageGalleryStoryCollectionViewInteractorTests.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 3/3/16.
//  Copyright © 2016 anton. All rights reserved.
//

import XCTest

#if QBRTCDemo_s
	@testable
	import QBRTCDemo_s
#elseif QBRTCDemo
	@testable
	import QBRTCDemo
#endif

class ImageGalleryStoryCollectionViewInteractorTests: XCTestCase {
	
	var interactor: ImageGalleryStoryCollectionViewInteractor!
	var mockOutput: MockPresenter!
	
	override func setUp() {
		super.setUp()
		self.interactor = ImageGalleryStoryCollectionViewInteractor()
		self.mockOutput = MockPresenter()
		self.interactor.output = mockOutput
	}
	
	// MARK: ImageGalleryStoryCollectionViewInteractorInput tests
	func testStartsAndNotificatesAboutSynchronizationImages() {
		// when
		self.interactor.addImage(UIImage())
		
		// then
		XCTAssertTrue(self.mockOutput.didUpdateImagesGotCalled)
		XCTAssertEqual(self.interactor.imagesCount(), 1)
	}
	
	func testCorrectlyRetrievesImage() {
		// when
		self.interactor.didReceiveImage(UIImage())
		
		// then
		XCTAssertNotNil(self.interactor.imageAt(0))
		XCTAssertNil(self.interactor.imageAt(1))
	}
	
	class MockPresenter: ImageGalleryStoryCollectionViewInteractorOutput {
		
		var didUpdateImagesGotCalled = false
		
		func didUpdateImages() {
			didUpdateImagesGotCalled = true
		}
	}
}