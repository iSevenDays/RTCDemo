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
	
	
	func didTriggerLoginButtonTapped(_ userName: String, roomName: String) {
		view.disableInput()
		interactor.signUpOrLoginWithUserName(userName, tags: [roomName])
	}
	
	func didReceiveUserName(_ userName: String, roomName: String) {
		
	}
}

extension AuthStoryPresenter: AuthStoryInteractorOutput {
	
	func didLoginUser(_ user: SVUser) {
		guard let firstTag = user.tags?.first else {
			NSLog("Error user has no tags")
			return
		}
		
		router.openChatUsersStoryWithTag(firstTag, currentUser: user)
	}
	
	func didErrorLogin(_ error: Error?) {
		DispatchQueue.main.async() { [view] in
			view?.showErrorLogin()
			view?.enableInput()
		}
	}
	
	func doingLoginWithUser(_ user: SVUser) {
		NSLog("%@", "doingLoginWithUser")
		DispatchQueue.main.async() { [view] in
			view?.showIndicatorLoggingIn()
			view?.setUserName(user.fullName)
			view?.setRoomName(user.tags!.joined(separator: ","))
			view?.disableInput()
		}
	}
	
	func doingLoginWithCachedUser(_ user: SVUser) {
		NSLog("%@", "doingLoginWithCachedUser")
		DispatchQueue.main.async() { [view] in
			view?.showIndicatorLoggingIn()
			view?.setUserName(user.fullName)
			view?.setRoomName(user.tags!.joined(separator: ","))
			view?.disableInput()
		}
	}
	
	func doingSignUpWithUser(_ user: SVUser) {
		DispatchQueue.main.async() { [view] in
			view?.showIndicatorSigningUp()
			view?.setUserName(user.fullName)
			view?.setRoomName(user.tags!.joined(separator: ","))
			view?.disableInput()
		}
	}
}

extension AuthStoryPresenter: AuthStoryModuleInput {
}
