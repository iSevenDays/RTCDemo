//
//  AuthStoryViewController.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

#if QBRTCDemo_s
	@testable
	import QBRTCDemo_s
#elseif QBRTCDemo
	@testable
	import QBRTCDemo
#endif

class AuthStoryViewController: UITableViewController, UITextFieldDelegate, AuthStoryViewInput {

    var output: AuthStoryViewOutput!

	@IBOutlet weak var userNameInput: UITextField!
	@IBOutlet weak var roomNameInput: UITextField!
	@IBOutlet weak var login: UIButton!
	
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
		
		userNameInput.addTarget(self, action: #selector(textFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
		roomNameInput.addTarget(self, action: #selector(textFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
		
		tableView.estimatedRowHeight = 80
    }

	func setInputEnabled(value: Bool) {
		self.userNameInput.enabled = value
		self.roomNameInput.enabled = value
		self.login.enabled = value
	}
	
	// MAKR: IBActions
	
	@IBAction func didTapLoginButton(sender: AnyObject) {
		let userName = userNameInput.text ?? ""
		let roomName = roomNameInput.text ?? ""
		self.output.didTriggerLoginButtonTapped(userName, roomName: roomName)
	}
	
    // MARK: AuthStoryViewInput
    func setupInitialState() {
    }
	
	func enableInput() {
		self.setInputEnabled(true)
	}
	
	func disableInput() {
		self.setInputEnabled(true)
	}
	
	func setUserName(userName: String) {
		self.userNameInput.text = userName
		updateLoginButtonEnabledState()
	}
	
	func setRoomName(roomName: String) {
		self.roomNameInput.text = roomName
		updateLoginButtonEnabledState()
	}
	
	func retrieveInformation() {
		let userName = self.userNameInput.text
		let roomName = self.roomNameInput.text
		
		self.output.didReceiveUserName(userName!, roomName: roomName!)
	}
	
	func showIndicatorLoggingIn() {
		print("Doing login")
	}
	
	func showIndicatorSigningUp() {
		print("Doing signup")
	}
	
	func showErrorLogin() {
		
	}
	
	// Mark: UITextFieldDelegate methods
	
	// Limit max length of tag text field to 15
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		if textField != roomNameInput {
			return true
		}
		
		// Prevent crashing undo bug – see http://stackoverflow.com/a/1773257/760518
		let charactersCount = textField.text?.characters.count ?? 0
		if range.length + range.location > charactersCount {
			return false
		}
		let newLength = charactersCount + string.characters.count - range.length
		return newLength <= 15
	}
	
	func textFieldDidChange(sender: AnyObject) {
		updateLoginButtonEnabledState()
	}
	
	func updateLoginButtonEnabledState() {
		let minCharactersCount = 3
		let userName = userNameInput.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		let tag = roomNameInput.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		
		login.enabled = userName?.characters.count >= minCharactersCount && tag?.characters.count >= minCharactersCount
	}

	// MARK: UITableViewDelegate
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
}
