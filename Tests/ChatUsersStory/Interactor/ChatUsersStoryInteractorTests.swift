//
//  ChatUsersStoryInteractorTests.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
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

class ChatUsersStoryInteractorTests: XCTestCase {

	var interactor: ChatUsersStoryInteractor!
	var mockOutput: MockPresenter!
	var mockCacheService: MockCacheService!
	var mockRESTService: MockRESTService!
	
	override func setUp() {
		super.setUp()
		interactor = ChatUsersStoryInteractor()
		mockOutput = MockPresenter()
		interactor.output = mockOutput

		mockCacheService = MockCacheService()
		interactor.cacheService = mockCacheService
		
		mockRESTService = MockRESTService()
		interactor.restService = mockRESTService
	}
	
	// MARK: ChatUsersStoryInteractorInput tests
	func testRetrievesUsersFromCacheAndDownloadsThemFromREST() {
		// given
		let cachedUsers = interactor.cacheService.cachedUsers()
		interactor.tag = "tag"
		
		// when
		interactor.retrieveUsersWithTag()
		
		// then
		XCTAssertTrue(mockOutput.didRetrieveUsersGotCalled)
		XCTAssertNotNil(mockOutput.retrievedUsers)
		XCTAssertEqualOptional(mockOutput.retrievedUsers, cachedUsers)
	}
	
	func testDownloadsUsersFromREST() {
		// given
		mockCacheService.cachedUsersArray = nil
		interactor.tag = "tag"
		
		// when
		interactor.retrieveUsersWithTag()
		
		// then
		XCTAssertTrue(mockRESTService.downloadUsersWithTagsGotCalled)
	}
	

    class MockPresenter: ChatUsersStoryInteractorOutput {
		var retrievedUsers: [SVUser]?
		var didRetrieveUsersGotCalled = false
		
		func didRetrieveUsers(users: [SVUser]) {
			didRetrieveUsersGotCalled = true
			retrievedUsers = users
		}
		
		func didErrorRetrievingUsers(error: NSError?) {
			
		}
    }
	
	class MockCacheService: CacheServiceProtocol {
		var cachedUsersArray: [SVUser]? = [TestsStorage.svuserTest()]
		
		func cacheUsers(users: [SVUser]) {
			cachedUsersArray = users
		}
		
		func cachedUsers() -> [SVUser]? {
			return cachedUsersArray
		}
	}
	
	class MockRESTService: FakeQBRESTService {
		var downloadUsersWithTagsGotCalled = false
		
		override func downloadUsersWithTags(tags: [String], successBlock: ((users: [SVUser]) -> Void)?, errorBlock: ((error: NSError?) -> Void)?) {
			downloadUsersWithTagsGotCalled = true
		}
	}
}
