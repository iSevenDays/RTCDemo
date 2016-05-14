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

	// ImageGalleryStoryModuleInput
	func configureWithCallService(callService: protocol<CallServiceProtocol, CallServiceDataChannelAdditionsProtocol>){
		interactor.configureWithCallService(callService)
		
		interactor.requestCallerRole()
	}
	
	// MARK: ImageGalleryStoryViewOutput
	
	func viewIsReady() {
		view.setupInitialState()
		
		interactor.configureCollectionView(self.view.collectionView())
	}
	
	func didTriggerStartButtonTapped() {
		interactor.startSynchronizationImages()
	}
	
	// MARK: ImageGalleryStoryInteractorOutput
	
	func didReceiveRoleSender() {
		
	}
	
	func didReceiveRoleReceiver() {
		view.configureViewForReceiving()
	}
	
	func didStartSynchronizationImages() {
		view.showSynchronizationImagesStarted()
	}
	
	func didFinishSynchronizationImages() {
		view.showSynchronizationImagesFinished()
	}
	
	// MARK: ImageGalleryStoryCollectionViewInteractorOutput
	
	func didUpdateImages() {
		view.reloadCollectionView()
	}
	
}
