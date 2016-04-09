//
//  AuthStoryInitializer.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class AuthStoryModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var viewController: AuthStoryViewController!

    override func awakeFromNib() {

        let configurator = AuthStoryModuleConfigurator()
        configurator.configureModuleForViewInput(viewController)
    }

}
