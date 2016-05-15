//
//  ChatUsersStoryPresenter.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

@objc class ChatUsersStoryPresenter: NSObject, ChatUsersStoryModuleInput, ChatUsersStoryViewOutput, ChatUsersStoryInteractorOutput {

    weak var view: ChatUsersStoryViewInput!
    var interactor: ChatUsersStoryInteractorInput!
    var router: ChatUsersStoryRouterInput!

	// MARK: ChatUsersStoryViewOutput
	
    func viewIsReady() {
		interactor.retrieveUsersWithTag()
    }
	
	func didTriggerUserTapped(user: SVUser) {
		router.openVideoStoryWithInitiator(interactor.retrieveCurrentUser(), thenCallOpponent: user)
	}
	
	// MARK: ChatUsersStoryModuleInput
	
	func setTag(tag: String, currentUser: SVUser) {
		interactor.setTag(tag, currentUser: currentUser)
		view.configureViewWithCurrentUser(currentUser)
	}
	
	// MARK: ChatUsersStoryInteractorOutput
	
	func didRetrieveUsers(users: [SVUser]) {
		view.reloadDataWithUsers(users)
	}
	
	func didReceiveCallRequestFromOpponent(opponent: SVUser) {
		router.openIncomingCallStoryWithOpponent(opponent)
	}
	
	
	func didError(error: ChatUsersStoryInteractorError) {
		
	}
}
