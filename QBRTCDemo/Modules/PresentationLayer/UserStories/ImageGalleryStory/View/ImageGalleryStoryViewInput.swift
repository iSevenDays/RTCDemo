//
//  ImageGalleryStoryViewInput.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/02/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

protocol ImageGalleryStoryViewInput: class {

    /**
        @author Anton Sokolchenko
        Setup initial state of the view
    */

	func showSynchronizationImagesStarted()
	func showSynchronizationImagesFinished()
	
    func setupInitialState()
	func configureViewForReceiving()
	
	func reloadCollectionView()
	
	func collectionView() -> ImageGalleryStoryCollectionView
}
