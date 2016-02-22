//
//  ImageGalleryStoryViewController.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/02/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class ImageGalleryStoryViewController: UIViewController, ImageGalleryStoryViewInput {

    var output: ImageGalleryStoryViewOutput!

	@IBOutlet weak var btnStartSynchronization: UIBarButtonItem!
	
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }

    // MARK: ImageGalleryStoryViewInput
    func setupInitialState() {
    }
	
	func configureViewForReceiving() {
		self.btnStartSynchronization.title = ""
		self.btnStartSynchronization.enabled = false
	}
	
	@IBAction func didTapStartButton(sender: AnyObject) {
		self.output.didTriggerStartButtonTaped()
	}
}
