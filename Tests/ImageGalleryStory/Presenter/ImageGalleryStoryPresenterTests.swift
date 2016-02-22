//
//  ImageGalleryStoryPresenterTests.swift
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

class ImageGalleryStoryPresenterTest: XCTestCase {
	var presenter: ImageGalleryStoryPresenter!
	var mockInteractor: MockInteractor!
	var mockRouter: MockRouter!
	var mockView: MockViewController!
	
    override func setUp() {
        super.setUp()
		self.presenter = ImageGalleryStoryPresenter()
		
		self.mockInteractor = MockInteractor()
		
		self.mockRouter = MockRouter()
		self.mockView = MockViewController()
		
		self.presenter.interactor = self.mockInteractor
		self.presenter.router = self.mockRouter
		self.presenter.view = self.mockView
    }
	
	//
	// MARK: ImageGalleryStoryInteractorInput tests
	//
	
	func testPresenterHandlesViewReadyEvent() {
		// given
		
		// when
		self.presenter.didTriggerStartButtonTaped()
		
		// then
		XCTAssertTrue(self.mockInteractor.startedSynchronizationImages)
	}

    class MockInteractor: ImageGalleryStoryInteractorInput {
		var startedSynchronizationImages = false
		
		func configureWithCallService(callService: protocol<CallServiceDataChannelAdditionsProtocol, CallServiceProtocol>) {
			
		}
		
		func startSynchronizationImages() {
			startedSynchronizationImages = true
		}
		
		func requestCallerRole() {
			
		}
    }

    class MockRouter: ImageGalleryStoryRouterInput {

    }

    class MockViewController: ImageGalleryStoryViewInput {

        func setupInitialState() {

        }
		
		func configureViewForReceiving() {
			
		}
    }
}
