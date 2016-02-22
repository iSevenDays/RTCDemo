//
//  ImageGalleryStoryPresenter.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/02/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class ImageGalleryStoryPresenter: NSObject, ImageGalleryStoryModuleInput, ImageGalleryStoryViewOutput, ImageGalleryStoryInteractorOutput {

    weak var view: ImageGalleryStoryViewInput!
    var interactor: ImageGalleryStoryInteractorInput!
    var router: ImageGalleryStoryRouterInput!

	func configureWithCallService(callService: protocol<CallServiceProtocol, CallServiceDataChannelAdditionsProtocol>){
		self.interactor.configureWithCallService(callService)
	}
	
	// MARK: ImageGalleryStoryViewOutput
	
	func viewIsReady() {
		self.interactor.requestCallerRole()
	}
	
	func didTriggerStartButtonTaped() {
		self.interactor.startSynchronizationImages()
	}
	
	// MARK: ImageGalleryStoryInteractorOutput
	
	func didReceiveRoleSender() {
		
	}
	
	func didReceiveRoleReceiver() {
		self.view.configureViewForReceiving()
	}
	
	func didStartSynchronizationImages() {
		
	}
	
	func didFinishSynchronizationImages() {
		
	}
	
	
}
