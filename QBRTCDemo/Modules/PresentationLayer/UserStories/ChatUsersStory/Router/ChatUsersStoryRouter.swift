//
//  ChatUsersStoryRouter.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class ChatUsersStoryRouter: ChatUsersStoryRouterInput {
	
	let chatUsersStoryToVideoCallStorySegueIdentifier = "ChatUsersStoryToVideoCallStorySegueIdentifier"
	let chatUsersStoryToIncomingCallStorySegueIdentifier = "ChatUsersStoryToIncomingCallStorySegueIdentifier"
	
	// ChatUsersViewController is transitionHandler
	@objc weak var transitionHandler: protocol<RamblerViperModuleTransitionHandlerProtocol>!
	
	func openVideoStoryWithInitiator(initiator: SVUser, thenCallOpponent opponent: SVUser) {
		
		transitionHandler.openModuleUsingSegue?(chatUsersStoryToVideoCallStorySegueIdentifier).thenChainUsingBlock({ (moduleInput) -> RamblerViperModuleOutput! in
			
			guard let videoStoryInput = moduleInput as? VideoCallStoryModuleInput else {
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
