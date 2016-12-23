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
		interactor.retrieveUsersWithTag()
	}
	
	func didTriggerUserTapped(user: SVUser) {
		router.openVideoStoryWithInitiator(interactor.retrieveCurrentUser(), thenCallOpponent: user)
	}
}

extension ChatUsersStoryPresenter: ChatUsersStoryModuleInput {
	func setTag(tag: String, currentUser: SVUser) {
		interactor.setTag(tag, currentUser: currentUser)
		view?.configureViewWithCurrentUser(currentUser)
	}
}

extension ChatUsersStoryPresenter: ChatUsersStoryInteractorOutput {
	func didRetrieveUsers(users: [SVUser]) {
		view?.reloadDataWithUsers(users)
	}
	
	func didReceiveCallRequestFromOpponent(opponent: SVUser) {
		router.openIncomingCallStoryWithOpponent(opponent)
	}
	
	func didReceiveHangupFromOpponent(opponent: SVUser) {
		
	}
	
	func didError(error: ChatUsersStoryInteractorError) {
		if error == .CanNotRetrieveUsers {
			view?.reloadDataWithUsers([])
		}
	}
}
