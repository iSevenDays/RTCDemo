//
//  SettingsStorySettingsStoryViewController.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/01/2017.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

import UIKit

class SettingsStoryViewController: UIViewController {

    @objc var output: SettingsStoryViewOutput!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }


    // MARK: SettingsStoryViewInput
    func setupInitialState() {
    }
}

extension SettingsStoryViewController: SettingsStoryViewInput {
	
}
