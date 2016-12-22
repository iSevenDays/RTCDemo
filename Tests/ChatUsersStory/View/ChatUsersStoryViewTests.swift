//
//  ChatUsersStoryViewTests.swift
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

class ChatUsersStoryViewTests: XCTestCase {

	var controller: ChatUsersStoryViewController!
	var mockOutput: MockViewControllerOutput!
	
	let emptySender = UIResponder()
	
    override func setUp() {
        super.setUp()
		controller = UIStoryboard(name: "ChatUsersStory", bundle: nil).instantiateViewControllerWithIdentifier(String(ChatUsersStoryViewController.self)) as! ChatUsersStoryViewController
		
		mockOutput = MockViewControllerOutput()
		controller.output = mockOutput
    }
	
	func testViewDidLoadTriggersViewIsReadyAction() {
		// when
		controller.viewDidLoad()
		
		// then
		XCTAssertTrue(mockOutput.viewIsReadyGotCalled)
	}
	
	func testViewCorrectlyLoadsAndShowsUsers() {
		// given
		controller.loadView()
		let users = [TestsStorage.svuserTest]
		let firstUser = users.first!
		
		// when
		controller.reloadDataWithUsers(users)
		
		// then
		let firstCell = controller.tableView.dataSource?.tableView(controller.tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? ChatUsersTableViewCell
		let numberOfRows = controller.tableView.dataSource?.tableView(controller.tableView, numberOfRowsInSection: 0)
		
		XCTAssertEqual(controller.users.count, 1)
		XCTAssertEqual(controller.users.count, numberOfRows)
		XCTAssertEqual(firstCell?.userFullName?.text, firstUser.fullName)
	}
	
	func testNavigationBarTextWithCurrentUser() {
		// given
		controller.loadView()
		let currentUser = TestsStorage.svuserTest
		
		// when
		controller.configureViewWithCurrentUser(currentUser)
		
		// then
		XCTAssertEqual(controller.navigationItem.title, "Logged in as " + currentUser.fullName)
	}
	
	func testTableHeaderViewHasHeaderWithCurrentUsersTag() {
		// given
		controller.loadView()
		let currentUser = TestsStorage.svuserTest
		
		// when
		controller.configureViewWithCurrentUser(currentUser)
		
		guard let roomName = currentUser.tags?.first else {
			XCTFail()
			return
		}
		
		// then
		XCTAssertEqual(controller.tableHeaderLbl.text, "Room \"\(roomName)\"")
	}
	
	func testViewCorrectlyHandlesUserTappedEvent() {
		// given
		controller.loadView()
		let users = [TestsStorage.svuserTest]
		let firstUser = users.first!
		
		// when
		controller.reloadDataWithUsers(users)
		
		// then
		controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
		
		XCTAssertTrue(mockOutput.didTriggerUserTappedGotCalled)
		XCTAssertEqual(mockOutput.user, firstUser)
	}
	
	// MARK: IBActions
	
	@objc class MockViewControllerOutput : NSObject,  ChatUsersStoryViewOutput {
		var viewIsReadyGotCalled = false
		
		var didTriggerUserTappedGotCalled = false
		var user: SVUser?
		
		func viewIsReady() {
			viewIsReadyGotCalled = true
		}
		
		func didTriggerUserTapped(user: SVUser) {
			didTriggerUserTappedGotCalled = true
			self.user = user
		}
		
	}

}
