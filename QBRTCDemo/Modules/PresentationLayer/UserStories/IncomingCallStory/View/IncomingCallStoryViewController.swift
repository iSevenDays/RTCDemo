//
//  IncomingCallStoryViewController.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class IncomingCallStoryViewController: UIViewController {

    @objc var output: IncomingCallStoryViewOutput!

	@IBOutlet weak var lblIncomingCall: UILabel!
	
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }
	
	// MARK: IBActions
	
	@IBAction func acceptCall(sender: AnyObject) {
		_ = view
		output.didTriggerAcceptButtonTapped()
	}
	
	@IBAction func declineCall(sender: AnyObject) {
		_ = view
		output.didTriggerDeclineButtonTapped()
	}
}

extension IncomingCallStoryViewController: IncomingCallStoryViewInput {
	func setupInitialState() {
		
	}
	
	func configureViewWithCallInitiator(callInitiator: SVUser) {
		_ = view
		lblIncomingCall.text = "Incoming call from " + callInitiator.fullName
		lblIncomingCall.hidden = false
	}
	
	func showOpponentDecidedToDeclineCall() {
		output.didTriggerCloseAction()
	}
}
