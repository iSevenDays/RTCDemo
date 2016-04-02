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

class AuthStoryViewController: UITableViewController, AuthStoryViewInput {

    var output: AuthStoryViewOutput!

	@IBOutlet weak var userNameInput: UITextField!
	@IBOutlet weak var roomNameInput: UITextField!
	@IBOutlet weak var login: UIButton!
	
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }

	func setInputEnabled(value: Bool) {
		self.userNameInput.enabled = value
		self.roomNameInput.enabled = value
		self.login.enabled = value
	}
	
	// MAKR: IBActions
	
	@IBAction func didTapLoginButton(sender: AnyObject) {
		self.output.didTriggerLoginButtonTapped()
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
	}
	
	func setRoomName(roomName: String) {
		self.roomNameInput.text = roomName
	}
	
	func retrieveInformation() {
		let userName = self.userNameInput.text ?? ""
		let roomName = self.roomNameInput.text ?? ""
		
		self.output.didReceiveUserName(userName, roomName: roomName)
	}
}
