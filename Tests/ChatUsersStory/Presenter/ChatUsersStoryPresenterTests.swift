//
//  ChatUsersStoryPresenterTests.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import XCTest

class ChatUsersStoryPresenterTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    class MockInteractor: ChatUsersStoryInteractorInput {

    }

    class MockRouter: ChatUsersStoryRouterInput {

    }

    class MockViewController: ChatUsersStoryViewInput {

        func setupInitialState() {

        }
    }
}
