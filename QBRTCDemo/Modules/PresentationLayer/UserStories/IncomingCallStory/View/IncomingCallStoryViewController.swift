//
//  IncomingCallStoryViewController.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class IncomingCallStoryViewController: UIViewController, IncomingCallStoryViewInput {

    @objc var output: IncomingCallStoryViewOutput!

	@IBOutlet weak var btnAcceptCall: UIButton!
	
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }
	

    // MARK: IncomingCallStoryViewInput
    func setupInitialState() {
    }
	
	// MARK: IBActions
	
	@IBAction func acceptCall() {
		output.didTriggerAcceptButtonTapped()
	}
}
