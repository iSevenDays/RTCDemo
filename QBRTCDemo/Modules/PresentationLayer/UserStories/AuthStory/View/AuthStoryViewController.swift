//
//  AuthStoryViewController.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class AuthStoryViewController: UIViewController, AuthStoryViewInput {

    var output: AuthStoryViewOutput!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }


    // MARK: AuthStoryViewInput
    func setupInitialState() {
    }
}
