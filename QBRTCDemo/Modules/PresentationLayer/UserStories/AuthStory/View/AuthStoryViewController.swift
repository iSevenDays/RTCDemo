//
//  AuthStoryViewController.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

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
		userNameInput.enabled = value
		roomNameInput.enabled = value
		login.enabled = value
	}
	
	// MAKR: IBActions
	
	@IBAction func didTapLoginButton(sender: AnyObject) {
		let userName = userNameInput.text ?? ""
		let roomName = roomNameInput.text ?? ""
		output.didTriggerLoginButtonTapped(userName, roomName: roomName)
	}
	
    // MARK: AuthStoryViewInput
    func setupInitialState() {
    }
	
	func enableInput() {
		setInputEnabled(true)
	}
	
	func disableInput() {
		setInputEnabled(true)
	}
	
	func setUserName(userName: String) {
		userNameInput.text = userName
		updateLoginButtonEnabledState()
	}
	
	func setRoomName(roomName: String) {
		roomNameInput.text = roomName
		updateLoginButtonEnabledState()
	}
	
	func retrieveInformation() {
		let userName = userNameInput.text
		let roomName = roomNameInput.text
		
		output.didReceiveUserName(userName!, roomName: roomName!)
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
