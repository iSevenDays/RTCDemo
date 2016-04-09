//
//  AuthStoryRouter.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class AuthStoryRouter: AuthStoryRouterInput {
	
	let authStoryToVideoStorySegueIdentifier = "AuthStoryToVideoStorySegue"
	
	@objc weak var transitionHandler: protocol<RamblerViperModuleTransitionHandlerProtocol>!;
	
	func openVideoStory() {
		transitionHandler.openModuleUsingSegue?(authStoryToVideoStorySegueIdentifier)
	}
}
