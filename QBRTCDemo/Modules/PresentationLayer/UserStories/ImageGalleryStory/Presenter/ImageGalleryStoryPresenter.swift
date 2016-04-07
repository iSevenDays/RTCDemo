//
//  ImageGalleryStoryPresenter.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/02/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

@objc class ImageGalleryStoryPresenter: NSObject, ImageGalleryStoryModuleInput, ImageGalleryStoryViewOutput, ImageGalleryStoryInteractorOutput, ImageGalleryStoryCollectionViewInteractorOutput {

    weak var view: ImageGalleryStoryViewInput!
    var interactor: ImageGalleryStoryInteractorInput!
    var router: ImageGalleryStoryRouterInput!

	
	func configureWithCallService(callService: protocol<CallServiceProtocol, CallServiceDataChannelAdditionsProtocol>){
		self.interactor.configureWithCallService(callService)
		
		self.interactor.requestCallerRole()
	}
	
	// MARK: ImageGalleryStoryViewOutput
	
	func viewIsReady() {
		self.view.setupInitialState()
		
		self.interactor.configureCollectionView(self.view.collectionView())
	}
	
	func didTriggerStartButtonTapped() {
		self.interactor.startSynchronizationImages()
	}
	
	// MARK: ImageGalleryStoryInteractorOutput
	
	func didReceiveRoleSender() {
		
	}
	
	func didReceiveRoleReceiver() {
		self.view.configureViewForReceiving()
	}
	
	func didStartSynchronizationImages() {
		self.view.showSynchronizationImagesStarted()
	}
	
	func didFinishSynchronizationImages() {
		self.view.showSynchronizationImagesFinished()
	}
	
	// MARK: ImageGalleryStoryCollectionViewInteractorOutput
	
	func didUpdateImages() {
		self.view.reloadCollectionView()
	}
	
}
