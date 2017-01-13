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
	var callService: FakeCallSevice!
	
	var testUser: SVUser!
	let tag = "tag"
	
	override func setUp() {
		super.setUp()
		interactor = ChatUsersStoryInteractor()
		mockOutput = MockPresenter()
		interactor.output = mockOutput

		mockCacheService = MockCacheService()
		interactor.cacheService = mockCacheService
		callService = FakeCallSevice()
		callService.signalingChannel = FakeSignalingChannel()
		interactor.callService = callService
		mockRESTService = MockRESTService()
		interactor.restService = mockRESTService
		
		testUser = TestsStorage.svuserTest
	}
	
	// MARK: ChatUsersStoryInteractorInput tests
	func testRetrievesUsersFromCacheAndDownloadsThemFromREST() {
		// given
		let cachedUsers = interactor.cacheService.cachedUsersForRoomWithName(tag)
		interactor.chatRoomName = tag
		
		// when
		interactor.retrieveUsersWithTag()
		
		// then
		XCTAssertTrue(mockOutput.didRetrieveUsersGotCalled)
		XCTAssertNotNil(mockOutput.retrievedUsers)
		XCTAssertEqualOptional(mockOutput.retrievedUsers, cachedUsers)
	}
	
	func testSetsTagIfTagContainMoreThanThreeCharacters() {
		// when
		interactor.setChatRoomName(tag)
		
		// then
		XCTAssertNil(mockOutput.error)
	}
	
	func testDoesNOTSetTagIfTagContainLessThanThreeCharacters() {
		// given
		let tag = "ta"
		
		// when
		interactor.setChatRoomName(tag)
		
		// then
		XCTAssertEqual(mockOutput.error, ChatUsersStoryInteractorError.TagLengthMustBeGreaterThanThreeCharacters)
	}
	
	func testDownloadsUsersFromRESTAndCaches() {
		// given
		mockCacheService.cachedUsersArray = nil
		interactor.chatRoomName = tag
		
		// when
		interactor.retrieveUsersWithTag()
		
		// then
		XCTAssertTrue(mockRESTService.downloadUsersWithTagsGotCalled)
		XCTAssertEqualOptional(mockCacheService.cachedUsersForRoomWithName("tag"), mockOutput.retrievedUsers) // users should be cached
		XCTAssertEqualOptional(mockOutput.retrievedUsers, mockRESTService.restUsersArray)
	}
	
	func testApprovesRequestedCallForOpponent_whenChatIsConnected() {
		// given
		callService.shouldBeConnected = true
		
		// when
		interactor.requestCallWithOpponent(testUser)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveApprovedRequestForCallWithOpponentGotCalled)
		XCTAssertFalse(mockOutput.didDeclineRequestForCallWithOpponentGotCalled)
	}
	
	func testDeclinesRequestedCallForOpponent_whenChatIsNOTConnected() {
		// given
		callService.shouldBeConnected = false
		
		// when
		interactor.requestCallWithOpponent(testUser)
		
		// then
		XCTAssertTrue(mockOutput.didDeclineRequestForCallWithOpponentGotCalled)
		XCTAssertFalse(mockOutput.didReceiveApprovedRequestForCallWithOpponentGotCalled)
	}
	
	// MARK: ChatUsersStoryInteractor CallServiceDelegate tests
	
	func testNotifiesPresenterAboutIncomingCall() {
		// given
		let tag = "tag"
		let opponentUser = TestsStorage.svuserRealUser1
		
		let fakeCallService = FakeCallSevice()
		ServicesConfigurator().configureCallService(fakeCallService)
		fakeCallService.signalingChannel = FakeSignalingChannel()
		
		// when
		interactor.setChatRoomName(tag)
		
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
		
		var didReceiveApprovedRequestForCallWithOpponentGotCalled = false
		var didDeclineRequestForCallWithOpponentGotCalled = false
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
		
		func didReceiveApprovedRequestForCallWithOpponent(opponent: SVUser) {
			didReceiveApprovedRequestForCallWithOpponentGotCalled = true
		}
		
		func didDeclineRequestForCallWithOpponent(opponent: SVUser, reason: String) {
			didDeclineRequestForCallWithOpponentGotCalled = true
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
