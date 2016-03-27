//
//  AuthStoryPresenterTests.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import XCTest

class AuthStoryPresenterTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    class MockInteractor: AuthStoryInteractorInput {

    }

    class MockRouter: AuthStoryRouterInput {

    }

    class MockViewController: AuthStoryViewInput {

        func setupInitialState() {

        }
    }
}
