//
//  ImageGalleryStoryViewOutput.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/02/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

@objc protocol ImageGalleryStoryViewOutput {

    /**
        @author Anton Sokolchenko
        Notify presenter that view is ready
    */

    func viewIsReady()
	
	func didTriggerStartButtonTaped()
}
