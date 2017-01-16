//
//  SettingsStorySettingsStoryInitializer.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/01/2017.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

import UIKit

class SettingsStoryModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var viewController: SettingsStoryViewController!

    override func awakeFromNib() {

        let configurator = SettingsStoryModuleConfigurator()
        configurator.configureModuleForViewInput(viewController)
    }
}
