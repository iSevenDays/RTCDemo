//
//  ChatUsersStoryRouter.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class ChatUsersStoryRouter: ChatUsersStoryRouterInput {
	
	let chatUsersStoryToVideoStorySegueIdentifier = "ChatUsersStoryToVideoStorySegueIdentifier"
	let chatUsersStoryToIncomingCallStorySegueIdentifier = "ChatUsersStoryToIncomingCallStorySegueIdentifier"
	
	// ChatUsersViewController is transitionHandler
	@objc weak var transitionHandler: protocol<RamblerViperModuleTransitionHandlerProtocol>!
	
	func openVideoStoryWithInitiator(initiator: SVUser, thenCallOpponent opponent: SVUser) {
		
		transitionHandler.openModuleUsingSegue?(chatUsersStoryToVideoStorySegueIdentifier).thenChainUsingBlock({ (moduleInput) -> RamblerViperModuleOutput! in
			
			guard let videoStoryInput = moduleInput as? VideoStoryModuleInput else {
				fatalError("moduleInput is not VideoStoryModuleInput")
			}
			
			videoStoryInput.connectToChatWithUser(initiator, callOpponent: opponent)
			
			return nil
		})
	}
	
	func openIncomingCallStoryWithOpponent(opponent: SVUser) {
		
		transitionHandler.openModuleUsingSegue?(chatUsersStoryToIncomingCallStorySegueIdentifier).thenChainUsingBlock({ (moduleInput) -> RamblerViperModuleOutput! in
			
			guard let incomingCallStoryInput = moduleInput as? IncomingCallStoryModuleInput else {
				fatalError("moduleInput is not IncomingCallStoryModuleInput")
			}
			
			incomingCallStoryInput.configureModuleWithCallInitiator(opponent)
			
			return nil
		})
		
	}
	
}
