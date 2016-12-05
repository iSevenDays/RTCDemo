//
//  AuthStoryRouter.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class AuthStoryRouter: AuthStoryRouterInput {
	
	let authStoryToChatUsersStorySegueIdentifier = "AuthStoryToChatUsersStorySegue"
	
	// AuthStoryViewController is transitionHandler
	@objc weak var transitionHandler: RamblerViperModuleTransitionHandlerProtocol!
	
	func openChatUsersStoryWithTag(tag: String, currentUser: SVUser) {
		
		transitionHandler.openModuleUsingSegue?(authStoryToChatUsersStorySegueIdentifier).thenChainUsingBlock({ (moduleInput) -> RamblerViperModuleOutput! in
			
			guard let chatUsersStoryInput = moduleInput as? ChatUsersStoryModuleInput else {
				fatalError("moduleInput is not ChatUsersStoryModuleInput")
			}
			
			chatUsersStoryInput.setTag(tag, currentUser: currentUser)
			
			return nil
		})
	}
}
