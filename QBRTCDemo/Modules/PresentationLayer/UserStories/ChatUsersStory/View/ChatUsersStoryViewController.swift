//
//  ChatUsersStoryViewController.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit


class ChatUsersStoryViewController: UIViewController {

    @objc var output: ChatUsersStoryViewOutput!
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var tableHeaderLbl: UILabel!
	
	internal var users: [SVUser] = []
	let randomColors = UIColor.randomColors()
	
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }
}

extension ChatUsersStoryViewController: ChatUsersStoryViewInput {
	func setupInitialState() {
		
	}
	
	func configureViewWithCurrentUser(user: SVUser) {
		navigationItem.title = "Logged in as " + user.fullName
		if let roomName = user.tags?.first {
			_ = view
			tableHeaderLbl.text = "Users in the room " + roomName
		}
	}
	
	func reloadDataWithUsers(users: [SVUser]) {
		
		self.users = users
		
		dispatch_async(dispatch_get_main_queue()) { [weak self] in
			self?.tableView.reloadData()
		}
		
	}
	
	@IBAction func prepareForUnwindFromVideoStoryToChatUsersStory(segue: UIStoryboardSegue) {
		
	}
}

let cellIdentifier = "ChatUsersCellIdentifier"

extension ChatUsersStoryViewController: UITableViewDataSource {
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return users.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ChatUsersTableViewCell
		
		guard indexPath.row < users.count else {
			fatalError("Error: data error, no user at indexPath")
		}
		
		let user = users[indexPath.row]
		
		cell.userFullName.text = user.fullName
		
		let randomColor = randomColors[indexPath.row % randomColors.count]
		
		
		cell.coloredRect.backgroundColor = UIColor(hex: randomColor, alpha: 1.0)
		cell.contentView.backgroundColor = UIColor(hex: randomColor, alpha: 0.3)
		
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
