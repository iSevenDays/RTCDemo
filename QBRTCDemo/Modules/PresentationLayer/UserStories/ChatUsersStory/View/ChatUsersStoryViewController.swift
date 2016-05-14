//
//  ChatUsersStoryViewController.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class ChatUsersStoryViewController: UIViewController, ChatUsersStoryViewInput {

    @objc var output: ChatUsersStoryViewOutput!
	
	@IBOutlet var tableView: UITableView!
	
	internal var users: [SVUser] = []
	
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }


    // MARK: ChatUsersStoryViewInput
    func setupInitialState() {
		
    }
	
	func configureViewWithCurrentUser(user: SVUser) {
		navigationItem.title = "Logged in as " + user.fullName
	}
	
	func reloadDataWithUsers(users: [SVUser]) {
		
		self.users = users
		
		dispatch_async(dispatch_get_main_queue()) { [weak self] in
			self?.tableView.reloadData()
		}
		
	}
	
}

let cellIdentifier = "ChatUsersCellIdentifier"

extension ChatUsersStoryViewController: UITableViewDataSource {
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return users.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
		
		guard indexPath.row < users.count else {
			fatalError("Error: data error, no user at indexPath")
		}
		
		let user = users[indexPath.row]
		
		cell.textLabel?.text = user.fullName
		cell.detailTextLabel?.text = String(user.ID)
		
		return cell
	}
}

extension ChatUsersStoryViewController: UITableViewDelegate {
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		guard indexPath.row < users.count else {
			fatalError("Error: data error, no user at indexPath")
		}
		
		let user = users[indexPath.row]
		
		output.didTriggerUserTapped(user)
	}
}