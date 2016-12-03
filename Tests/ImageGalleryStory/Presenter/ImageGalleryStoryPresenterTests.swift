//
//  ImageGalleryStoryPresenterTests.swift
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
		// when
		self.presenter.viewIsReady()
		
		// then
		XCTAssertTrue(self.mockView.setupInitialStateGotCalled)
		XCTAssertTrue(self.mockView.collectionViewGotCalled)
		XCTAssertTrue(self.mockInteractor.configureCollectionViewGotCalled)
	}
	
	func testPresenterHandlesStartButtonTapedEvent() {
		// when
		self.presenter.didTriggerStartButtonTapped()
		
		// then
		XCTAssertTrue(self.mockInteractor.startSynchronizationImagesGotCalled)
	}
	
	func testPresenterConfiguresModule() {
		// when
		self.presenter.configureModule()
		
		// then
		XCTAssertTrue(self.mockInteractor.requestCallerRoleGotCalled)
	}
	
	//
	// MARK: ImageGalleryStoryViewInput tests
	//
	
	func testPresenterConfiguresView_whenReceiver() {
		// when
		self.presenter.didReceiveRoleReceiver();
		
		// then
		XCTAssertTrue(self.mockView.configureViewForReceivingGotCalled)
	}
	
	func testPresentedHandlesDidStartSynchronizationImages() {
		// when
		self.presenter.didStartSynchronizationImages()
		
		// then
		XCTAssertTrue(self.mockView.showSynchronizationImagesStartedGotCalled)
	}
	
	func testPresentedHandlesDidFinishSynchronizationImages() {
		// when
		self.presenter.didFinishSynchronizationImages()
		
		// then
		XCTAssertTrue(self.mockView.showSynchronizationImagesFinishedGotCalled)
	}
	
	// MARK: ImageGalleryStoryCollectionViewInteractorOutput
	
	func testPresenterCallsReloadCollectionView_onDidUpdateImages() {
		// when
		self.presenter.didUpdateImages();
		
		// then
		XCTAssertTrue(self.mockView.reloadCollectionViewGotCalled)
	}

    class MockInteractor: ImageGalleryStoryInteractorInput {
		var startSynchronizationImagesGotCalled = false
		
		var configureWithCallServiceGotCalled = false
		var configureCollectionViewGotCalled = false
		var requestCallerRoleGotCalled = false
		
		func startSynchronizationImages() {
			startSynchronizationImagesGotCalled = true
		}
		
		func requestCallerRole() {
			requestCallerRoleGotCalled = true
		}
		
		func configureCollectionView(collectionView: ImageGalleryStoryCollectionView) {
			configureCollectionViewGotCalled = true
		}
    }

    class MockRouter: ImageGalleryStoryRouterInput {

    }

    class MockViewController: ImageGalleryStoryViewInput {
		
		var configureViewForReceivingGotCalled = false
		var reloadCollectionViewGotCalled = false
		var collectionViewGotCalled = false
		
		var setupInitialStateGotCalled = false
		var showSynchronizationImagesStartedGotCalled = false
		var showSynchronizationImagesFinishedGotCalled = false
		
        func setupInitialState() {
			setupInitialStateGotCalled = true
        }
		
		func configureViewForReceiving() {
			configureViewForReceivingGotCalled = true
		}
		
		func reloadCollectionView() {
			reloadCollectionViewGotCalled = true
		}
		
		func showSynchronizationImagesStarted() {
			showSynchronizationImagesStartedGotCalled = true
		}
		
		func showSynchronizationImagesFinished() {
			showSynchronizationImagesFinishedGotCalled = true
		}

		func collectionView() -> ImageGalleryStoryCollectionView {
			collectionViewGotCalled = true
			let collection = ImageGalleryStoryCollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
			return collection
		}
    }
}
