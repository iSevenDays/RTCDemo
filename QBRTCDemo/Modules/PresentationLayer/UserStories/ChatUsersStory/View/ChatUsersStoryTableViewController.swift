//
//  ChatUsersStoryTableViewController.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class ChatUsersStoryTableViewController: UIViewController, ChatUsersStoryViewInput {

    @objc var output: ChatUsersStoryViewOutput!
	
	@IBOutlet var tableView: UITableView!
	
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }


    // MARK: ChatUsersStoryViewInput
    func setupInitialState() {
		
    }
	
	
	func reloadData() {
		tableView.reloadData()
	}
	
}

extension ChatUsersStoryTableViewController: UITableViewDataSource {
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		return UITableViewCell.init()
	}
}