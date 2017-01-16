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
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	var alertControl: AlertControlProtocol!
	
	internal var users: [SVUser] = []
	let randomColors = UIColor.randomColors()
	let cellIdentifier = "ChatUsersCellIdentifier"
	
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }
	
	@IBAction func openSettings(sender: UIButton) {
		output.didTriggerSettingsButtonTapped()
	}
}

extension ChatUsersStoryViewController: ChatUsersStoryViewInput {
	func setupInitialState() {
		activityIndicator.startAnimating()
	}
	
	func configureViewWithCurrentUser(user: SVUser) {
		navigationItem.title = "Logged in as " + user.fullName
		if let roomName = user.tags?.first {
			_ = view
			tableHeaderLbl.text = "Room \"\(roomName)\""
		}
	}
	
	func reloadDataWithUsers(users: [SVUser]) {
		activityIndicator.stopAnimating()
		
		self.users = users
		
		guard self.users.count != 0 else {
			if let emptyView = ChatUsersStoryEmptyView.instanceFromNib() {
				tableView.backgroundView = emptyView
			}
			tableView.reloadData()
			return
		}
		
		tableView.backgroundView = nil
		tableView.reloadData()
	}
	
	func showErrorMessage(message: String) {
		alertControl.showErrorMessage(message, overViewController: self, completion: nil)
	}
	
	@IBAction func prepareForUnwindFromVideoStoryToChatUsersStory(segue: UIStoryboardSegue) {
		
	}
}

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
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		guard indexPath.row < users.count else {
			NSLog("%@%", "Error: data error, no user at indexPath")
			return
		}
		
		let user = users[indexPath.row]
		
		output.didTriggerUserTapped(user)
	}
}
