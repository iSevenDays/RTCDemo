//
//  ImageGalleryStoryPresenter.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/02/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class ImageGalleryStoryPresenter: NSObject, ImageGalleryStoryModuleInput, ImageGalleryStoryViewOutput, ImageGalleryStoryInteractorOutput, ImageGalleryStoryCollectionViewInteractorOutput {

    weak var view: ImageGalleryStoryViewInput!
    var interactor: ImageGalleryStoryInteractorInput!
    var router: ImageGalleryStoryRouterInput!

	// ImageGalleryStoryModuleInput
	func configureModule(){
		interactor.requestCallerRole()
	}
	
	// MARK: ImageGalleryStoryViewOutput
	
	func viewIsReady() {
		view.setupInitialState()
		
		interactor.configureCollectionView(view.collectionView())
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
