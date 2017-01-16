//
//  ChatUsersStoryPresenter.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

@objc class ChatUsersStoryPresenter: NSObject {

    weak var view: ChatUsersStoryViewInput?
    var interactor: ChatUsersStoryInteractorInput!
    var router: ChatUsersStoryRouterInput!
}

extension ChatUsersStoryPresenter: ChatUsersStoryViewOutput {
	func viewIsReady() {
		view?.setupInitialState()
		interactor.retrieveUsersWithTag()
	}
	
	func didTriggerUserTapped(user: SVUser) {
		interactor.requestCallWithOpponent(user)
	}
	
	func didTriggerSettingsButtonTapped() {
		router.openSettingsStory()
	}
}

extension ChatUsersStoryPresenter: ChatUsersStoryModuleInput {
	func setTag(tag: String, currentUser: SVUser) {
		interactor.setChatRoomName(tag)
		view?.configureViewWithCurrentUser(currentUser)
	}
}

extension ChatUsersStoryPresenter: ChatUsersStoryInteractorOutput {
	func didRetrieveUsers(users: [SVUser]) {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view?.reloadDataWithUsers(users)
		}
		interactor.notifyUsersAboutCurrentUserEnteredRoom()
	}
	
	func didReceiveCallRequestFromOpponent(opponent: SVUser) {
		router.openIncomingCallStoryWithOpponent(opponent)
	}
	
	func didError(error: ChatUsersStoryInteractorError) {
		if error == .CanNotRetrieveUsers {
			view?.reloadDataWithUsers([])
		}
	}
	
	func didReceiveApprovedRequestForCallWithOpponent(opponent: SVUser) {
		router.openVideoStoryWithInitiator(interactor.retrieveCurrentUser(), thenCallOpponent: opponent)
	}
	
	func didDeclineRequestForCallWithOpponent(opponent: SVUser, reason: String) {
		view?.showErrorMessage(reason)
	}
	
	func didReceiveHangupFromOpponent(opponent: SVUser) {
	}
	func didSetChatRoomName(chatRoomName: String) {
	}
	func didNotifyUsersAboutCurrentUserEnteredRoom() {
	}
	func didFailToNotifyUsersAboutCurrentUserEnteredRoom() {
	}
}
