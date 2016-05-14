//
//  AuthStoryPresenter.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class AuthStoryPresenter: AuthStoryModuleInput, AuthStoryViewOutput, AuthStoryInteractorOutput{

    weak var view: AuthStoryViewInput!
    var interactor: AuthStoryInteractorInput!
    var router: AuthStoryRouterInput!

	
	// MARK: AuthStoryViewOutput
	
    func viewIsReady() {
		interactor.tryRetrieveCachedUser()
    }
	
	
	func didTriggerLoginButtonTapped(userName: String, roomName: String) {
		interactor.signUpOrLoginWithUserName(userName, tags: [roomName])
	}
	
	func didReceiveUserName(userName: String, roomName: String) {
		
	}
	
	// MARK: AuthStoryInteractorOutput
	
	func didLoginUser(user: SVUser) {
		guard let firstTag = user.tags?.first else {
			NSLog("Error user has no tags")
			return
		}
		
		router.openChatUsersStoryWithTag(firstTag, currentUser: user)
	}
	
	func didErrorLogin(error: NSError?) {
		view.showErrorLogin()
	}
	
	func doingLoginWithUser(user: SVUser) {
		view.showIndicatorLoggingIn()
		view.setUserName(user.fullName)
		view.setRoomName(user.tags!.joinWithSeparator(","))
	}
	
	func doingLoginWithCachedUser(user: SVUser) {
		view.showIndicatorLoggingIn()
		view.setUserName(user.fullName)
		view.setRoomName(user.tags!.joinWithSeparator(","))
	}
	
	func doingSignUpWithUser(user: SVUser) {
		view.showIndicatorSigningUp()
		view.setUserName(user.fullName)
		view.setRoomName(user.tags!.joinWithSeparator(","))
	}
}
