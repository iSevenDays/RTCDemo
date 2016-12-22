//
//  AuthStoryViewController.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class AuthStoryViewController: UITableViewController {

    var output: AuthStoryViewOutput!

	@IBOutlet weak var userNameInput: UITextField!
	@IBOutlet weak var roomNameInput: UITextField!
	@IBOutlet weak var login: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
		
		userNameInput.addTarget(self, action: #selector(textFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
		roomNameInput.addTarget(self, action: #selector(textFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
		
		tableView.estimatedRowHeight = 80
    }

	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		activityIndicator.stopAnimating()
		enableInput()
	}
	
	private func setInputEnabled(value: Bool) {
		userNameInput.enabled = value
		roomNameInput.enabled = value
		login.enabled = value
	}
	
	private func updateLoginButtonEnabledState() {
		let minCharactersCount = 3
		let userName = userNameInput.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		let tag = roomNameInput.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		
		login.enabled = userName?.characters.count >= minCharactersCount && tag?.characters.count >= minCharactersCount
	}
	
	// MAKR: IBActions
	
	@IBAction func didTapLoginButton(sender: UIButton) {
		let userName = userNameInput.text ?? ""
		let roomName = roomNameInput.text ?? ""
		output.didTriggerLoginButtonTapped(userName, roomName: roomName)
	}
}

// MARK: AuthStoryViewInput
extension AuthStoryViewController: AuthStoryViewInput {
    func setupInitialState() {
    }
	
	func enableInput() {
		setInputEnabled(true)
	}
	
	func disableInput() {
		setInputEnabled(false)
	}
	
	func setUserName(userName: String) {
		userNameInput.text = userName
	}
	
	func setRoomName(roomName: String) {
		roomNameInput.text = roomName
	}
	
	func retrieveInformation() {
		let userName = userNameInput.text
		let roomName = roomNameInput.text
		
		output.didReceiveUserName(userName!, roomName: roomName!)
	}
	
	func showIndicatorLoggingIn() {
		activityIndicator.startAnimating()
		print("Doing login")
	}
	
	func showIndicatorSigningUp() {
		activityIndicator.startAnimating()
		print("Doing signup")
	}
	
	func showErrorLogin() {
		enableInput()
		activityIndicator.stopAnimating()
		AlertControl.showErrorMessage("Can not login, please try again later", overViewController: self)
	}
}
	// Mark: UITextFieldDelegate methods
	
extension AuthStoryViewController: UITextFieldDelegate {
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
	
	
}

// MARK: UITableViewDelegate
extension AuthStoryViewController {
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
}
