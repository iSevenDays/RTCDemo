//
//  ChatUsersStoryRouter.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class ChatUsersStoryRouter {
	
	let chatUsersStoryToVideoCallStorySegueIdentifier = "ChatUsersStoryToVideoCallStorySegueIdentifier"
	let chatUsersStoryToIncomingCallStorySegueIdentifier = "ChatUsersStoryToIncomingCallStorySegueIdentifier"
	let chatUsersStoryToSettingsStorySegueIdentifier = "ChatUsersStoryToSettingsStorySegueIdentifier"
	
	// ChatUsersViewController is transitionHandler
	@objc weak var transitionHandler: protocol<RamblerViperModuleTransitionHandlerProtocol>!
}

extension ChatUsersStoryRouter: ChatUsersStoryRouterInput {
	func openVideoStoryWithInitiator(initiator: SVUser, thenCallOpponent opponent: SVUser) {
		
		transitionHandler.openModuleUsingSegue?(chatUsersStoryToVideoCallStorySegueIdentifier).thenChainUsingBlock({ (moduleInput) -> RamblerViperModuleOutput! in
			
			guard let videoStoryInput = moduleInput as? VideoCallStoryModuleInput else {
				fatalError("moduleInput is not VideoStoryModuleInput")
			}
			
			videoStoryInput.startCallWithOpponent(opponent)
			
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
	
	func openSettingsStory() {
		transitionHandler.openModuleUsingSegue?(chatUsersStoryToSettingsStorySegueIdentifier)
	}
	
}
