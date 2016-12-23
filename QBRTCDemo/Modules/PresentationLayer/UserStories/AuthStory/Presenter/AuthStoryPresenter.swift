//
//  AuthStoryPresenter.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class AuthStoryPresenter: NSObject {
	
	weak var view: AuthStoryViewInput!
	var interactor: AuthStoryInteractorInput!
	var router: AuthStoryRouterInput!
	
}

extension AuthStoryPresenter: AuthStoryViewOutput {
	func viewIsReady() {
		interactor.tryLoginWithCachedUser()
	}
	
	
	func didTriggerLoginButtonTapped(userName: String, roomName: String) {
		view.disableInput()
		interactor.signUpOrLoginWithUserName(userName, tags: [roomName])
	}
	
	func didReceiveUserName(userName: String, roomName: String) {
		
	}
}

extension AuthStoryPresenter: AuthStoryInteractorOutput {
	
	func didLoginUser(user: SVUser) {
		guard let firstTag = user.tags?.first else {
			NSLog("Error user has no tags")
			return
		}
		
		router.openChatUsersStoryWithTag(firstTag, currentUser: user)
	}
	
	func didErrorLogin(error: NSError?) {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view.showErrorLogin()
			view.enableInput()
		}
	}
	
	func doingLoginWithUser(user: SVUser) {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view.showIndicatorLoggingIn()
			view.setUserName(user.fullName)
			view.setRoomName(user.tags!.joinWithSeparator(","))
		}
	}
	
	func doingLoginWithCachedUser(user: SVUser) {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view.showIndicatorLoggingIn()
			view.setUserName(user.fullName)
			view.setRoomName(user.tags!.joinWithSeparator(","))
			view.disableInput()
		}
	}
	
	func doingSignUpWithUser(user: SVUser) {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view.showIndicatorSigningUp()
			view.setUserName(user.fullName)
			view.setRoomName(user.tags!.joinWithSeparator(","))
			view.disableInput()
		}
	}
}

extension AuthStoryPresenter: AuthStoryModuleInput {
}
