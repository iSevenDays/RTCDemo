//
//  ChatUsersStoryPresenter.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class ChatUsersStoryPresenter: NSObject {

    weak var view: ChatUsersStoryViewInput?
    var interactor: ChatUsersStoryInteractorInput!
    var router: ChatUsersStoryRouterInput!
}

extension ChatUsersStoryPresenter: ChatUsersStoryViewOutput {
	func viewIsReady() {
		view?.setupInitialState()
		interactor.retrieveUsersWithTag()
	}
	
	func didTriggerUserTapped(_ user: SVUser) {
		interactor.requestCallWithOpponent(user)
	}
	
	func didTriggerSettingsButtonTapped() {
		router.openSettingsStory()
	}
}

extension ChatUsersStoryPresenter: ChatUsersStoryModuleInput {
	func setTag(_ tag: String, currentUser: SVUser) {
		interactor.setChatRoomName(tag)
		view?.configureViewWithCurrentUser(currentUser)
	}
}

extension ChatUsersStoryPresenter: ChatUsersStoryInteractorOutput {
	func didRetrieveUsers(_ users: [SVUser]) {
		DispatchQueue.main.async() { [view] in
			view?.reloadDataWithUsers(users)
		}
		interactor.notifyUsersAboutCurrentUserEnteredRoom()
	}
	
	func didReceiveCallRequestFromOpponent(_ opponent: SVUser) {
		router.openIncomingCallStoryWithOpponent(opponent)
	}
	
	func didError(_ error: ChatUsersStoryInteractorError) {
		if error == .canNotRetrieveUsers {
			view?.reloadDataWithUsers([])
		}
	}
	
	func didReceiveApprovedRequestForCallWithOpponent(_ opponent: SVUser) {
		router.openVideoStoryWithInitiator(interactor.retrieveCurrentUser(), thenCallOpponent: opponent)
	}
	
	func didDeclineRequestForCallWithOpponent(_ opponent: SVUser, reason: String) {
		view?.showErrorMessage(reason)
	}
	
	func didReceiveHangupFromOpponent(_ opponent: SVUser) {
	}
	func didSetChatRoomName(_ chatRoomName: String) {
	}
	func didNotifyUsersAboutCurrentUserEnteredRoom() {
	}
	func didFailToNotifyUsersAboutCurrentUserEnteredRoom() {
	}
}
