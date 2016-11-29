//
//  ImageGalleryStoryViewController.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/02/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class ImageGalleryStoryViewController: UIViewController, ImageGalleryStoryViewInput {

    @objc var output: ImageGalleryStoryViewOutput!

	@IBOutlet weak var imageCollectionView: ImageGalleryStoryCollectionView!
	@IBOutlet weak var btnStartSynchronization: UIBarButtonItem!
	
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }

	@IBAction func didTapStartButton(sender: AnyObject) {
		output.didTriggerStartButtonTapped()
	}
	
    // MARK: ImageGalleryStoryViewInput
    func setupInitialState() {
    }
	
	func collectionView() -> ImageGalleryStoryCollectionView {
		assert(imageCollectionView != nil)
		
		return imageCollectionView
	}
	
	func configureViewForReceiving() {
		btnStartSynchronization.title = ""
		btnStartSynchronization.enabled = false
	}
	
	func reloadCollectionView() {
		dispatch_async(dispatch_get_main_queue()) {[weak self] () -> Void in
			
			self?.imageCollectionView.collectionViewLayout.invalidateLayout()
			self?.imageCollectionView.reloadData()
			
		}
	}
	
	func showSynchronizationImagesStarted() {
		
	}
	
	func showSynchronizationImagesFinished() {
		
	}
}
