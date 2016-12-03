//
//  IncomingCallStoryInitializer.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class IncomingCallStoryModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var viewController: IncomingCallStoryViewController!

    override func awakeFromNib() {

        let configurator = IncomingCallStoryModuleConfigurator()
        configurator.configureModuleForViewInput(viewController)
    }

}
