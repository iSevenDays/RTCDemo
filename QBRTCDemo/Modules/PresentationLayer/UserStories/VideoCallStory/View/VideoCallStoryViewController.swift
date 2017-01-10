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
	
	// MARK - IBOutlets
	
	@IBOutlet weak var btnSwitchCamera: DesignableButton!
	@IBOutlet weak var imgSwitchCamera: UIImageView!
	
	// switch local audio track state
	@IBOutlet weak var btnMute: DesignableButton!
	
	// switch local video track state
	@IBOutlet weak var btnSwitchLocalVideoTrackState: DesignableButton!
	
	@IBOutlet weak var lblState: UILabel!
	@IBOutlet weak var viewRemote: RTCEAGLVideoView!
	@IBOutlet weak var viewLocal: RTCCameraPreviewView!
	@IBOutlet weak var videoCameraImgView: UIImageView!
	
	var localVideoTrackStateAuthorized = true
	var microphoneStateAuthorized = true
	
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
		output.didTriggerSwitchLocalVideoTrackStateButtonTapped()
	}
	
	@IBAction func didTapButtonMicrophone(sender: UIButton) {
		output.didTriggerMicrophoneButtonTapped()
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
		
		imgSwitchCamera.hidden = !enabled
		viewLocal.hidden = !enabled
		btnSwitchCamera.hidden = !enabled
		btnSwitchLocalVideoTrackState.selected = !enabled
	}
	
	func showLocalAudioTrackEnabled(enabled: Bool) {
		btnMute.selected = !enabled
	}
	
	func showLocalVideoTrackAuthorized() {
		viewLocal.hidden = false
	}
	
	func showLocalVideoTrackDenied() {
		localVideoTrackStateAuthorized = false
		
		// Local view area
		viewLocal.hidden = true
		btnSwitchCamera.selected = true
		btnSwitchCamera.setImage(UIImage(named: "block"), forState: .Normal)
		btnSwitchCamera.contentVerticalAlignment = .Center
		btnSwitchCamera.contentHorizontalAlignment = .Center
		
		// Bottom button
		btnSwitchLocalVideoTrackState.setImage(UIImage(named: "videoBlock"), forState: .Normal)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)

		let settingsAction = UIAlertAction(title: "Go To Settings", style: .Cancel) { _ in
			if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
				UIApplication.sharedApplication().openURL(url)
			}
		}
		
		alertControl.showMessage("Please allow camera access for video calls. If you cancel, the opponent will NOT be able to see you", title: "Permissions warning", overViewController: self, actions: [cancelAction, settingsAction], completion: nil)
	}
	
	func showMicrophoneAuthorized() {
		btnMute.hidden = false
	}
	
	func showMicrophoneDenied() {
		microphoneStateAuthorized = false
		
		btnMute.setImage(UIImage(named: "microphoneDenied"), forState: .Normal)
		btnMute.setImage(UIImage(named: "microphoneDenied"), forState: .Selected)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
		
		let settingsAction = UIAlertAction(title: "Go To Settings", style: .Cancel) { _ in
			if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
				UIApplication.sharedApplication().openURL(url)
			}
		}
		
		alertControl.showMessage("Please allow microphone access for video calls. If you cancel, the opponent will NOT be able to hear you", title: "Permissions warning", overViewController: self, actions: [cancelAction, settingsAction], completion: nil)
	}
	
	func showCameraPosition(backCamera: Bool) {
		let animation = CATransition()
		animation.duration = 0.5
		animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		animation.type = "oglFlip"
		if backCamera {
			animation.subtype = kCATransitionFromRight
		} else {
			animation.subtype = kCATransitionFromLeft
		}
		viewLocal.layer.addAnimation(animation, forKey: kCATransition)
	}
	
	// Currently not used
	func showErrorDataChannelNotReady() {
		
	}
}
