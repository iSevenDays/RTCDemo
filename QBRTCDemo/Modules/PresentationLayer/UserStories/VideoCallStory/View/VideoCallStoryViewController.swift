//
//  VideoCallStoryViewController.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class VideoCallStoryViewController: UIViewController {
	
	var alertControl: AlertControlProtocol!
	
	@objc var output: VideoCallStoryViewOutput!
	@IBOutlet weak var btnSwitchCamera: UIButton!
	
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
	
	@IBAction func didTapButtonSwitchLocalVideoTrack(sender: UIButton) {
		output.didTriggerSwitchLocalVideoTrackButtonTapped()
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
		alertControl.showMessage("Opponent is busy, please call later", title: "Notification", overViewController: self, completion: { [output] in
			output.didTriggerCloseButtonTapped()
			})
	}
	
	func showOpponentHangup() {
		alertControl.showMessage("Opponent ended the call", title: "Notification", overViewController: self, completion: { [output] in
			output.didTriggerCloseButtonTapped()
			})
	}
	
	func showOpponentAnswerTimeout() {
		alertControl.showMessage("Opponent isn't answering. Please try again later", title: "Notification", overViewController: self, completion: { [output] in
			output.didTriggerCloseButtonTapped()
			})
	}
	
	func showErrorConnect() {
		alertControl.showErrorMessage("Can not connect. Please try again later", overViewController: self, completion: nil)
	}
	
	func showErrorCallServiceDisconnected() {
		alertControl.showErrorMessage("Disconnected. Can not connect. Please try again later", overViewController: self, completion: { [output] in
			output.didTriggerCloseButtonTapped()
			})
	}
	
	func setLocalVideoCaptureSession(captureSession: AVCaptureSession) {
		_ = view
		viewLocal.captureSession = captureSession
	}
	
	func configureRemoteVideoViewWithBlock(block: ((RTCEAGLVideoView?) -> Void)?) {
		block?(viewRemote)
	}
	
	func showLocalVideoTrackEnabled(enabled: Bool) {
		let shouldDisplayCameraDeniedState = !enabled
		btnSwitchCamera.hidden = shouldDisplayCameraDeniedState
		btnSwitchCamera.selected = shouldDisplayCameraDeniedState
	}
	
	// Currently not used
	func showErrorDataChannelNotReady() {
		
	}
}
