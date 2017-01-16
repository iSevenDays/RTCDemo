//
//  SettingsStorySettingsStoryPresenterTests.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/01/2017.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

import XCTest

#if QBRTCDemo_s
	@testable
	import QBRTCDemo_s
#elseif QBRTCDemo
	@testable
	import QBRTCDemo
#endif

class SettingsStoryPresenterTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    class MockInteractor: SettingsStoryInteractorInput {
		func requestFullHDVideoQualityEnabled(enabled: Bool) {
			
		}
    }

    class MockRouter: SettingsStoryRouterInput {

    }

    class MockViewController: SettingsStoryViewInput {

        func setupInitialState() {

        }
		
		func showFullHDVideoQualityEnabled(enabled: Bool) {
			
		}
    }
}
