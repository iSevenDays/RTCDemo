//
//  ImageGalleryStoryInitializer.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/02/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class ImageGalleryStoryModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var viewController: ImageGalleryStoryViewController!

    override func awakeFromNib() {

        let configurator = ImageGalleryStoryModuleConfigurator()
        configurator.configureModuleForViewInput(viewController)
    }

}
