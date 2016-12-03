//
//  ChatUsersStoryInitializer.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class ChatUsersStoryModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var viewController: ChatUsersStoryViewController!

    override func awakeFromNib() {

        let configurator = ChatUsersStoryModuleConfigurator()
        configurator.configureModuleForViewInput(viewController)
    }

}
