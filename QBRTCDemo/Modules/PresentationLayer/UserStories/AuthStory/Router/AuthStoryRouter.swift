//
//  AuthStoryRouter.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class AuthStoryRouter: AuthStoryRouterInput {
	
	let authStoryToChatUsersStorySegueIdentifier = "AuthStoryToChatUsersStorySegue"
	
	@objc weak var transitionHandler: protocol<RamblerViperModuleTransitionHandlerProtocol>!;
	
	func openChatUsersStoryWithTag(tag: String) {
		transitionHandler.openModuleUsingSegue?(authStoryToChatUsersStorySegueIdentifier).thenChainUsingBlock({ (moduleInput) -> RamblerViperModuleOutput! in
			
			guard let chatUsersStoryInput = moduleInput as? ChatUsersStoryModuleInput else {
				fatalError("moduleInput is not ChatUsersStoryModuleInput")
			}
			
			chatUsersStoryInput.setTag(tag)
			
			return nil
		})
	}
}
