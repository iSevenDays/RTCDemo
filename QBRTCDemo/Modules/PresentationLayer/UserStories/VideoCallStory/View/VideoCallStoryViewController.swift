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
	@IBOutlet weak var btnSwitchCamera: DesignableButton!
	
	// MARK - IBOutlets
	@IBOutlet weak var lblState: UILabel!
	@IBOutlet weak var viewRemote: RTCEAGLVideoView!
	@IBOutlet weak var viewLocal: RTCCameraPreviewView!
	
	var localVideoTrackStateAuthorized = true
	
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
		// Video can not be enabled until user granted the permission
		guard localVideoTrackStateAuthorized else { return }
		
		btnSwitchCamera.selected = !enabled
	}
	
	func showLocalVideoTrackAuthorized() {
		viewLocal.hidden = false
	}
	
	func showLocalVideoTrackDenied() {
		localVideoTrackStateAuthorized = false
		
		viewLocal.hidden = true
		btnSwitchCamera.selected = true
		btnSwitchCamera.setImage(UIImage(named: "block"), forState: .Normal)
		btnSwitchCamera.contentVerticalAlignment = .Center
		btnSwitchCamera.contentHorizontalAlignment = .Center
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)

		let settingsAction = UIAlertAction(title: "Go To Settings", style: .Cancel) { _ in
			if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
				UIApplication.sharedApplication().openURL(url)
			}
		}
		
		alertControl.showMessage("Please allow camera access for video calls. If you cancel, the opponent will NOT be able to see you", title: "Permissions warning", overViewController: self, actions: [cancelAction, settingsAction], completion: nil)
	}
	
	// Currently not used
	func showErrorDataChannelNotReady() {
		
	}
}
