//
//  VideoCallStoryInitializer.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class VideoCallStoryModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var viewController: VideoCallStoryViewController!

    override func awakeFromNib() {

        let configurator = VideoCallStoryModuleConfigurator()
        configurator.configureModuleForViewInput(viewController)
    }

}
