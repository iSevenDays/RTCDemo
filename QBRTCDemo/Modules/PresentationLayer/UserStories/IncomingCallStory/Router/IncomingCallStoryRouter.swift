//
//  IncomingCallStoryRouter.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class IncomingCallStoryRouter: IncomingCallStoryRouterInput {
	
	let incomingCallStoryToVideoStorySegue = "IncomingCallStoryToVideoStorySegue"
	let incomingCallStoryToChatsUserStoryModuleSegue = "IncomingCallStoryToChatsUserStoryModuleUnwindSegue"
	
	// AuthStoryViewController is transitionHandler
	@objc weak var transitionHandler: RamblerViperModuleTransitionHandlerProtocol!
	
	func openVideoStoryWithOpponent(_ opponent: SVUser) {

		transitionHandler.openModule?(usingSegue: incomingCallStoryToVideoStorySegue)?.thenChain({ (moduleInput) -> RamblerViperModuleOutput? in

			guard let videoStoryInput = moduleInput as? VideoCallStoryModuleInput else {
				fatalError("moduleInput is not VideoStoryModuleInput")
			}

			videoStoryInput.acceptCallFromOpponent(opponent)

			return nil
		})
	}
	
	func unwindToChatsUserStory() {
		transitionHandler.openModule?(usingSegue: incomingCallStoryToChatsUserStoryModuleSegue)
	}
}
