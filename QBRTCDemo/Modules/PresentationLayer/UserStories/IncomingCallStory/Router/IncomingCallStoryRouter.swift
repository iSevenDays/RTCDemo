//
//  IncomingCallStoryRouter.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class IncomingCallStoryRouter: IncomingCallStoryRouterInput {
	
	let incomingCallStoryToVideoStorySegue = "IncomingCallStoryToVideoStorySegue"
	
	// AuthStoryViewController is transitionHandler
	@objc weak var transitionHandler: protocol<RamblerViperModuleTransitionHandlerProtocol>!
	
	func openVideoStoryWithOpponent(opponent: SVUser) {
		
		transitionHandler.openModuleUsingSegue?(incomingCallStoryToVideoStorySegue).thenChainUsingBlock({ (moduleInput) -> RamblerViperModuleOutput! in
			
			guard let videoStoryInput = moduleInput as? VideoStoryModuleInput else {
				fatalError("moduleInput is not VideoStoryModuleInput")
			}
			
			videoStoryInput.acceptCallFromOpponent(opponent)
			
			return nil
		})
	}
	
}
