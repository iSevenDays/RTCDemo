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
	
	func DISABLE_testPresenterHandlesViewReadyEvent() {
		// given
		
		// when
		self.presenter.viewIsReady()
		
		// then
		XCTAssertTrue(self.mockView.collectionViewGotCalled)
		XCTAssertTrue(self.mockInteractor.configureCollectionViewGotCalled)
	}
	
	func testPresenterHandlesStartButtonTapedEvent() {
		// given
		
		// when
		self.presenter.didTriggerStartButtonTaped()
		
		// then
		XCTAssertTrue(self.mockInteractor.startedSynchronizationImages)
	}
	
	func testPresenterConfiguresModule() {
		// given
		let callService = CallService(signalingChannel: FakeSignalingChannel(), callServiceDelegate: nil, dataChannelDelegate: nil)
		// when
		self.presenter.configureWithCallService(callService!)
		
		// then
		XCTAssertTrue(self.mockInteractor.configureWithCallServiceGotCalled)
	}
	
	func testPresenterConfiguresView_whenReceiver() {
		// when
		self.presenter.didReceiveRoleReceiver();
		
		// then
		XCTAssertTrue(self.mockView.configureViewForReceivingGotCalled)
	}
	
	func testPresenterCallsReloadCollectionView_onDidUpdateImages() {
		// when
		self.presenter.didUpdateImages();
		
		// then
		XCTAssertTrue(self.mockView.reloadCollectionViewGotCalled)
	}

    class MockInteractor: ImageGalleryStoryInteractorInput {
		var startedSynchronizationImages = false
		
		var configureWithCallServiceGotCalled = false
		var configureCollectionViewGotCalled = false
		
		func configureWithCallService(callService: protocol<CallServiceDataChannelAdditionsProtocol, CallServiceProtocol>) {
			configureWithCallServiceGotCalled = true
		}
		
		func startSynchronizationImages() {
			startedSynchronizationImages = true
		}
		
		func requestCallerRole() {
			
		}
		
		func configureCollectionView(collectionView: ImageGalleryStoryCollectionView) {
			configureCollectionViewGotCalled = false
		}
    }

    class MockRouter: ImageGalleryStoryRouterInput {

    }

    class MockViewController: ImageGalleryStoryViewInput {
		
		var configureViewForReceivingGotCalled = false
		var reloadCollectionViewGotCalled = false
		var collectionViewGotCalled = false
        func setupInitialState() {

        }
		
		func configureViewForReceiving() {
			configureViewForReceivingGotCalled = true
		}
		
		func reloadCollectionView() {
			reloadCollectionViewGotCalled = true
		}
// TODO fix crash
		func collectionView() -> ImageGalleryStoryCollectionView {
			collectionViewGotCalled = false
			let collection = ImageGalleryStoryCollectionView()
			return collection
		}
    }
}
