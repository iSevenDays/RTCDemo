//
//  ImageGalleryStoryPresenter.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/02/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class ImageGalleryStoryPresenter: ImageGalleryStoryModuleInput, ImageGalleryStoryViewOutput, ImageGalleryStoryInteractorOutput{

    weak var view: ImageGalleryStoryViewInput!
    var interactor: ImageGalleryStoryInteractorInput!
    var router: ImageGalleryStoryRouterInput!

    func viewIsReady() {

    }
	
	// MARK: ImageGalleryStoryViewOutput
	
	func didTriggerStartButtonTaped() {
		self.interactor.startSynchronizationImages()
	}
	
	// MARK: ImageGalleryStoryViewInput
	
	func didStartSynchronizationImages() {
		
	}
	
}
