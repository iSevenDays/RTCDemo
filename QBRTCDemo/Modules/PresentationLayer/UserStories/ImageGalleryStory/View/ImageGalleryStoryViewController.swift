//
//  ImageGalleryStoryViewController.swift
//  QBRTCDemo
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
		self.output.didTriggerStartButtonTapped()
	}
	
    // MARK: ImageGalleryStoryViewInput
    func setupInitialState() {
    }
	
	func collectionView() -> ImageGalleryStoryCollectionView {
		assert(self.imageCollectionView != nil)
		
		return self.imageCollectionView
	}
	
	func configureViewForReceiving() {
		self.btnStartSynchronization.title = ""
		self.btnStartSynchronization.enabled = false
	}
	
	func reloadCollectionView() {
		dispatch_async(dispatch_get_main_queue()) { () -> Void in
			
			self.imageCollectionView.collectionViewLayout.invalidateLayout()
			self.imageCollectionView.reloadData()
			
		}
	}
}
