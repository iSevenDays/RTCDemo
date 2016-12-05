//
//  VideoCallStoryRouter.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class VideoCallStoryRouter {

	// VideoCallStoryViewController is transitionHandler
	@objc weak var transitionHandler: RamblerViperModuleTransitionHandlerProtocol!
	let videoStoryToImageGalleryModuleSegue = "VideoStoryToImageGalleryModuleSegue"
	let videoStoryToChatsUserStoryModuleSegue = "VideoStoryToChatsUserStoryModuleUnwindSegue"
}

extension VideoCallStoryRouter: VideoCallStoryRouterInput {
	func openImageGallery() {
		
		transitionHandler.openModuleUsingSegue?(videoStoryToImageGalleryModuleSegue).thenChainUsingBlock { (moduleInput) -> RamblerViperModuleOutput! in
			
			guard let imageGalleryModuleInput = moduleInput as? ImageGalleryStoryModuleInput else {
				fatalError("moduleInput is not ImageGalleryStoryModuleInput")
			}
			
			imageGalleryModuleInput.configureModule()
			
			return nil
		}
	}
	
	func unwindToChatsUserStory() {
		transitionHandler.openModuleUsingSegue?(videoStoryToChatsUserStoryModuleSegue)
	}
}
