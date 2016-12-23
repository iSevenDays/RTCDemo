//
//  ChatUsersStoryInteractorTests.swift
//  RTCDemo
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
		let cachedUsers = interactor.cacheService.cachedUsersForRoomWithName("tag")
		interactor.tag = "tag"
		
		// when
		interactor.retrieveUsersWithTag()
		
		// then
		XCTAssertTrue(mockOutput.didRetrieveUsersGotCalled)
		XCTAssertNotNil(mockOutput.retrievedUsers)
		XCTAssertEqualOptional(mockOutput.retrievedUsers, cachedUsers)
	}
	
	func testSetsTagIfTagContainMoreThanThreeCharacters() {
		// given
		let tag = "tag"
		let testUser = TestsStorage.svuserTest
		
		// when
		interactor.setTag(tag, currentUser: testUser)
		
		// then
		XCTAssertNil(mockOutput.error)
		XCTAssertEqual(interactor.retrieveCurrentUser(), testUser)
	}
	
	func testDoesNOTSetTagIfTagContainLessThanThreeCharacters() {
		// given
		let tag = "ta"
		let testUser = TestsStorage.svuserTest
		
		// when
		interactor.setTag(tag, currentUser: testUser)
		
		// then
		XCTAssertEqual(mockOutput.error, ChatUsersStoryInteractorError.TagLengthMustBeGreaterThanThreeCharacters)
	}
	
	func testDownloadsUsersFromRESTAndCaches() {
		// given
		mockCacheService.cachedUsersArray = nil
		interactor.tag = "tag"
		
		// when
		interactor.retrieveUsersWithTag()
		
		// then
		XCTAssertTrue(mockRESTService.downloadUsersWithTagsGotCalled)
		XCTAssertEqualOptional(mockCacheService.cachedUsersForRoomWithName("tag"), mockOutput.retrievedUsers) // users should be cached
		XCTAssertEqualOptional(mockOutput.retrievedUsers, mockRESTService.restUsersArray)
	}
	
	// MARK: ChatUsersStoryInteractor CallServiceDelegate tests
	
	func testNotifiesPresenterAboutIncomingCall() {
		// given
		let tag = "tag"
		let currentUser = TestsStorage.svuserTest
		let opponentUser = TestsStorage.svuserRealUser1
		
		let fakeCallService = FakeCallSevice()
		ServicesConfigurator().configureCallService(fakeCallService)
		fakeCallService.signalingChannel = FakeSignalingChannel()
		
		// when
		interactor.setTag(tag, currentUser: currentUser)
		
		interactor.callService(fakeCallService, didReceiveCallRequestFromOpponent: opponentUser)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveCallRequestFromOpponentGotCalled)
		XCTAssertEqual(mockOutput.opponent, opponentUser)
	}
	
	
    class MockPresenter: ChatUsersStoryInteractorOutput {
		var retrievedUsers: [SVUser]?
		var didRetrieveUsersGotCalled = false
		
		var didReceiveCallRequestFromOpponentGotCalled = false
		var opponent: SVUser?
		
		var error: ChatUsersStoryInteractorError?
		
		func didRetrieveUsers(users: [SVUser]) {
			didRetrieveUsersGotCalled = true
			retrievedUsers = users
		}
		
		func didError(error: ChatUsersStoryInteractorError) {
			self.error = error
		}
		
		func didReceiveCallRequestFromOpponent(opponent: SVUser) {
			self.opponent = opponent
			didReceiveCallRequestFromOpponentGotCalled = true
		}
    }
	
	
	class MockCacheService: NSObject, CacheServiceProtocol {
		var cachedUsersArray: [SVUser]? = [TestsStorage.svuserTest]
		
		func setBool(value: Bool, forKey defaultName: String) {
			
		}
		
		func boolForKey(defaultName: String) -> Bool {
			return true
		}
		
		func cachedUserWithID(id: Int) -> SVUser? {
			return nil
		}
		
		func cacheUsers(users: [SVUser], forRoomName roomName: String) {
			cachedUsersArray = users
		}
		
		func cachedUsersForRoomWithName(roomName: String) -> [SVUser]? {
			return cachedUsersArray
		}
	}
	
	class MockRESTService: FakeQBRESTService {
		var downloadUsersWithTagsGotCalled = false
		var restUsersArray: [SVUser] = [TestsStorage.svuserTest]
		
		override func downloadUsersWithTags(tags: [String], successBlock: ((users: [SVUser]) -> Void)?, errorBlock: ((error: NSError?) -> Void)?) {
			downloadUsersWithTagsGotCalled = true
			successBlock?(users: restUsersArray)
		}
	}
}
