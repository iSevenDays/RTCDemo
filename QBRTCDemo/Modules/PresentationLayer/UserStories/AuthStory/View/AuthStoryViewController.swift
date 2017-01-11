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
	var alertControl: AlertControlProtocol!
	
	@IBOutlet weak var userNameInput: UITextField!
	@IBOutlet weak var roomNameInput: UITextField!
	@IBOutlet weak var login: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	let minCharactersCount = 3
	
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tap)
        output.viewIsReady()
	}

	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		activityIndicator.stopAnimating()
		enableInput()
	}
	
	func dismissKeyboard() {
		view.endEditing(true)
	}
	
	private func setInputEnabled(value: Bool) {
		userNameInput.enabled = value
		roomNameInput.enabled = value
		login.enabled = value
	}
	
	func validateLogin() -> Bool {
		if let userName = userNameInput.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) {
			return userName.characters.count >= minCharactersCount
		}
		return false
	}
	
	func validateRoomName() -> Bool {
		if let roomName = roomNameInput.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) {
			return roomName.characters.count >= minCharactersCount
		}
		return false
	}
	
	// MAKR: IBActions
	
	@IBAction func didTapLoginButton(sender: UIButton) {
		guard validateLogin() else {
			userNameInput.shake(3, for: 0.2, withTranslation: 14)
			return
		}
		
		guard validateRoomName() else {
			roomNameInput.shake(3, for: 0.2, withTranslation: 14)
			return
		}
		
		userNameInput.resignFirstResponder()
		roomNameInput.resignFirstResponder()
		
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
		activityIndicator.stopAnimating()
		alertControl.showErrorMessage("Can not login, please try again later", overViewController: self, completion: nil)
	}
}

// MARK: UITextFieldDelegate methods
extension AuthStoryViewController: UITextFieldDelegate {
	// Limit max length of tag text field to 15
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		if string.isEmpty {
			return true // allow backspace
		}
		
		if textField != roomNameInput {
			return true
		} else if textField == roomNameInput {
			// First letter must be a character, not a digit
			let textFieldIsEmtpy = textField.text?.isEmpty ?? true
			if textFieldIsEmtpy {
				if string.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet) == nil  {
					return false
				}
			}
		}
		
		// No white spaces
		guard string.rangeOfCharacterFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == nil else {
			return false
		}
		
		// Allow only alphanumeric characters
		guard string.rangeOfCharacterFromSet(NSCharacterSet.alphanumericCharacterSet()) != nil else {
			return false
		}
		
		// Prevent crashing undo bug – see http://stackoverflow.com/a/1773257/760518
		let charactersCount = textField.text?.characters.count ?? 0
		if range.length + range.location > charactersCount {
			return false
		}
		let newLength = charactersCount + string.characters.count - range.length
		return newLength <= 15
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		if textField == userNameInput {
			roomNameInput.becomeFirstResponder()
		} else if textField == roomNameInput {
			didTapLoginButton(login)
		}
		return validateLogin() && validateRoomName()
	}
}
