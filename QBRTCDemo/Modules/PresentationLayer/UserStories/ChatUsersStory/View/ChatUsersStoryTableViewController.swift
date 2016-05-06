//
//  ChatUsersStoryTableViewController.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class ChatUsersStoryTableViewController: UITableViewController, ChatUsersStoryViewInput {

    var output: ChatUsersStoryViewOutput!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }


    // MARK: ChatUsersStoryViewInput
    func setupInitialState() {
    }
}
