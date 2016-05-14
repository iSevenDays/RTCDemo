//
//  IncomingCallStoryPresenterTests.swift
//  QBRTCDemo
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


class IncomingCallStoryPresenterTest: XCTestCase {

	var presenter: IncomingCallStoryPresenter!
	var mockInteractor: MockInteractor!
	var mockRouter: MockRouter!
	var mockView: MockViewController!
	
	override func setUp() {
		super.setUp()
		
		self.presenter = IncomingCallStoryPresenter()
		
		self.mockInteractor = MockInteractor()
		
		self.mockRouter = MockRouter()
		self.mockView = MockViewController()
		
		self.presenter.interactor = self.mockInteractor
		self.presenter.router = self.mockRouter
		self.presenter.view = self.mockView
	}

    class MockInteractor: IncomingCallStoryInteractorInput {

    }

	class MockRouter: IncomingCallStoryRouterInput {
		func openVideoStoryWithInitiator(initiator: SVUser, thenCallOpponent opponent: SVUser) {
			
		}
    }

    class MockViewController: IncomingCallStoryViewInput {

        func setupInitialState() {

        }
    }
}
