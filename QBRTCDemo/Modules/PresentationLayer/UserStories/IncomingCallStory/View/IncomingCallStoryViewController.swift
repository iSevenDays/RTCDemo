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
	
	@IBAction func acceptCall(_ sender: AnyObject) {
		_ = view
		output.didTriggerAcceptButtonTapped()
	}
	
	@IBAction func declineCall(_ sender: AnyObject) {
		_ = view
		output.didTriggerDeclineButtonTapped()
	}
}

extension IncomingCallStoryViewController: IncomingCallStoryViewInput {
	@objc func setupInitialState() {
		
	}
	
	func configureViewWithCallInitiator(_ callInitiator: SVUser) {
		_ = view
		lblIncomingCall.text = "Incoming call from " + callInitiator.fullName
		lblIncomingCall.isHidden = false
	}
	
	func showOpponentDecidedToDeclineCall() {
		output.didTriggerCloseAction()
	}
	
	func hideView() {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) { [view] in
			let v = UIView(frame: (view?.frame)!)
			v.backgroundColor = UIColor.black
			view?.addSubview(v)
		}
	}
}
