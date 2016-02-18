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

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }

    // MARK: ImageGalleryStoryViewInput
    func setupInitialState() {
    }
	
	@IBAction func didTapStartButton(sender: AnyObject) {
		self.output.didTriggerStartButtonTaped()
	}
}
