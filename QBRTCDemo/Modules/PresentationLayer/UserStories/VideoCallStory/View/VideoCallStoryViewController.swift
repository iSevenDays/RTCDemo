//
//  VideoCallStoryViewController.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class VideoCallStoryViewController: UIViewController {
	
	@objc var output: VideoCallStoryViewOutput!
	
	// MARK - IBOutlets
	@IBOutlet weak var lblState: UILabel!
	@IBOutlet weak var viewRemote: RTCEAGLVideoView!
	@IBOutlet weak var viewLocal: RTCCameraPreviewView!
	
	// MARK: Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		output.viewIsReady()
	}
	
	// MARK: - IBActions
	
	@IBAction func didTapButtonHangup(sender: UIButton) {
		output.didTriggerHangupButtonTapped()
	}
	
	@IBAction func didTapButtonDataChannelImageGallery(sender: UIButton) {
		output.didTriggerDataChannelButtonTapped()
	}
	
	@IBAction func didTapButtonSwitchCamera(sender: UIButton) {
		output.didTriggerSwitchCameraButtonTapped()
	}
	
	@IBAction func didTapButtonSwitchAudioRoute(sender: UIButton) {
		sender.selected = !sender.selected
		output.didTriggerSwitchAudioRouteButtonTapped()
	}
}

extension VideoCallStoryViewController: VideoCallStoryViewInput {
	func setupInitialState() {
		navigationItem.title = "Connecting..."
	}
	
	func configureViewWithUser(user: SVUser) {
		
	}
	
	func showStartDialingOpponent(opponent: SVUser) {
		navigationItem.title = "Dialing \(opponent.fullName)..."
	}
	
	func showReceivedAnswerFromOpponent(opponent: SVUser) {
		navigationItem.title = "Call with \(opponent.fullName)"
	}
	
	func showHangup() {
		output.didTriggerCloseButtonTapped()
	}
	
	func showOpponentReject() {
		AlertControl.showMessage("Opponent is busy, please call later", title: "Notification", overViewController: self, completion: { [output] in
			output.didTriggerCloseButtonTapped()
			})
	}
	
	func showOpponentHangup() {
		AlertControl.showMessage("Opponent ended the call", title: "Notification", overViewController: self, completion: { [output] in
			output.didTriggerCloseButtonTapped()
			})
	}
	
	func showOpponentAnswerTimeout() {
		AlertControl.showMessage("Opponent isn't answering. Please try again later", title: "Notification", overViewController: self, completion: { [output] in
			output.didTriggerCloseButtonTapped()
			})
	}
	
	func showErrorConnect() {
		AlertControl.showErrorMessage("Can not connect. Please try again later", overViewController: self)
	}
	
	func showErrorCallServiceDisconnected() {
		AlertControl.showErrorMessage("Disconnected. Can not connect. Please try again later", overViewController: self, completion: { [output] in
			output.didTriggerCloseButtonTapped()
			})
	}
	
	func showErrorDataChannelNotReady() {
		
	}
	
	func setLocalVideoCaptureSession(captureSession: AVCaptureSession) {
		_ = view
		viewLocal.captureSession = captureSession
	}
	
	func configureRemoteVideoViewWithBlock(block: ((RTCEAGLVideoView?) -> Void)?) {
		block?(viewRemote)
	}
}
