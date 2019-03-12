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
	@IBOutlet weak var viewRemote: RenderableView!
	@IBOutlet weak var viewLocal: RenderableView!
	@IBOutlet weak var videoCameraImgView: UIImageView!

	var viewLocalRender: RenderableView!
	var viewRemoteRender: RenderableView!
	
	var localVideoTrackStateAuthorized = true
	var microphoneStateAuthorized = true
	
	// MARK: Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		output.viewIsReady()
	}
	
	// MARK: - IBActions
	
	@IBAction func didTapButtonHangup(_ sender: UIButton) {
		output.didTriggerHangupButtonTapped()
	}
	
	@IBAction func didTapButtonDataChannelImageGallery(_ sender: UIButton) {
		output.didTriggerDataChannelButtonTapped()
	}
	
	@IBAction func didTapButtonSwitchCamera(_ sender: UIButton) {
		output.didTriggerSwitchCameraButtonTapped()
	}
	
	@IBAction func didTapButtonSwitchAudioRoute(_ sender: UIButton) {
		sender.isSelected = !sender.isSelected
		output.didTriggerSwitchAudioRouteButtonTapped()
	}
	
	@IBAction func didTapButtonSwitchLocalVideoTrack(_ sender: UIButton) {
		output.didTriggerSwitchLocalVideoTrackStateButtonTapped()
	}
	
	@IBAction func didTapButtonMicrophone(_ sender: UIButton) {
		output.didTriggerMicrophoneButtonTapped()
	}
}

extension VideoCallStoryViewController: VideoCallStoryViewInput {
	func setupInitialState() {
		loadViewIfNeeded()
		navigationItem.title = "Connecting..."

		#if arch(arm64)
		// Using metal (arm64 only)
		viewLocalRender = RTCMTLVideoView(frame: self.viewLocal?.frame ?? CGRect.zero)
		viewRemoteRender = RTCMTLVideoView(frame: self.viewRemote.frame)
		(viewLocalRender as? RTCMTLVideoView)?.videoContentMode = .scaleAspectFill
		(viewRemoteRender as? RTCMTLVideoView)?.videoContentMode = .scaleAspectFill
		#else
		// Using OpenGLES for the rest
		viewLocalRender = RTCEAGLVideoView(frame: self.viewLocal?.frame ?? CGRect.zero)
		viewRemoteRender = RTCEAGLVideoView(frame: self.viewRemote.frame)
		#endif
		if let localVideoView = self.viewLocal {
			self.embedView(viewLocalRender, into: localVideoView)
		}
		self.embedView(viewRemoteRender, into: self.viewRemote)
	}

	private func embedView(_ view: UIView, into containerView: UIView) {
		containerView.addSubview(view)
		view.translatesAutoresizingMaskIntoConstraints = false
		containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
																	options: [],
																	metrics: nil,
																	views: ["view":view]))

		containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
																	options: [],
																	metrics: nil,
																	views: ["view":view]))
		containerView.layoutIfNeeded()
	}

	func configureViewWithUser(_ user: SVUser) {
		
	}
	
	func showStartDialingOpponent(_ opponent: SVUser) {
		navigationItem.title = "Dialing \(opponent.fullName)..."
	}
	
	func showCurrentUserAcceptedCallFromOpponent(_ opponent: SVUser) {
		navigationItem.title = "Call with \(opponent.fullName)"
	}
	
	func showReceivedAnswerFromOpponent(_ opponent: SVUser) {
		navigationItem.title = "Call with \(opponent.fullName)"
	}
	
	func showHangup() {
		output.didTriggerCloseButtonTapped()
	}
	
	func showOpponentReject() {
		alertControl.showMessage("Opponent is busy, please call later", title: "Notification", overViewController: self, completion: { [output] in
			output?.didTriggerCloseButtonTapped()
			})
	}
	
	func showOpponentHangup() {
		alertControl.showMessage("Opponent ended the call", title: "Notification", overViewController: self, completion: { [output] in
			output?.didTriggerCloseButtonTapped()
			})
	}
	
	func showOpponentAnswerTimeout() {
		alertControl.showMessage("Opponent isn't answering. Please try again later", title: "Notification", overViewController: self, completion: { [output] in
			output?.didTriggerCloseButtonTapped()
			})
	}
	
	func showErrorConnect() {
		alertControl.showErrorMessage("Can not connect. Please try again later", overViewController: self, completion: nil)
	}
	
	func showErrorCallServiceDisconnected() {
		alertControl.showErrorMessage("Disconnected. Can not connect. Please try again later", overViewController: self, completion: { [output] in
			output?.didTriggerCloseButtonTapped()
			})
	}

	func configureLocalVideoViewWithBlock(_ block: ((RenderableView?) -> Void)?) {
		loadViewIfNeeded()
		block?(viewLocalRender)
	}

	func configureRemoteVideoViewWithBlock(_ block: ((RenderableView?) -> Void)?) {
		loadViewIfNeeded()
		block?(viewRemoteRender)
	}
	
	func showLocalVideoTrackEnabled(_ enabled: Bool) {
		loadViewIfNeeded()
		// Video can not be enabled until user granted the permission
		guard localVideoTrackStateAuthorized else { return }
		
		imgSwitchCamera.isHidden = !enabled
		viewLocal.isHidden = !enabled
		btnSwitchCamera.isHidden = !enabled
		btnSwitchLocalVideoTrackState.isSelected = !enabled
	}
	
	func showLocalAudioTrackEnabled(_ enabled: Bool) {
		loadViewIfNeeded()
		btnMute.isSelected = !enabled
	}
	
	func showLocalVideoTrackAuthorized() {
		loadViewIfNeeded()
		viewLocal.isHidden = false
	}
	
	func showLocalVideoTrackDenied() {
		loadViewIfNeeded()
		localVideoTrackStateAuthorized = false
		
		// Local view area
		viewLocal.isHidden = true
		btnSwitchCamera.isSelected = true
		btnSwitchCamera.setImage(UIImage(named: "block"), for: .normal)
		btnSwitchCamera.contentVerticalAlignment = .center
		btnSwitchCamera.contentHorizontalAlignment = .center
		
		// Bottom button
		btnSwitchLocalVideoTrackState.setImage(UIImage(named: "videoBlock"), for: .normal)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

		let settingsAction = UIAlertAction(title: "Go To Settings", style: .cancel) { _ in
			if let url = URL(string: UIApplication.openSettingsURLString) {
				UIApplication.shared.openURL(url)
			}
		}
		
		alertControl.showMessage("Please allow camera access for video calls. If you cancel, the opponent will NOT be able to see you", title: "Permissions warning", overViewController: self, actions: [cancelAction, settingsAction], completion: nil)
	}
	
	func showMicrophoneAuthorized() {
		btnMute.isHidden = false
	}
	
	func showMicrophoneDenied() {
		microphoneStateAuthorized = false
		
		btnMute.setImage(UIImage(named: "microphoneDenied"), for: .normal)
		btnMute.setImage(UIImage(named: "microphoneDenied"), for: .selected)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
		
		let settingsAction = UIAlertAction(title: "Go To Settings", style: .cancel) { _ in
			if let url = URL(string: UIApplication.openSettingsURLString) {
				UIApplication.shared.openURL(url)
			}
		}
		
		alertControl.showMessage("Please allow microphone access for video calls. If you cancel, the opponent will NOT be able to hear you", title: "Permissions warning", overViewController: self, actions: [cancelAction, settingsAction], completion: nil)
	}
	
	func showCameraPosition(_ backCamera: Bool) {
		let animation = CATransition()
		animation.duration = 0.5
		animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
		animation.type = convertToCATransitionType("oglFlip")
		if backCamera {
			animation.subtype = CATransitionSubtype.fromRight
		} else {
			animation.subtype = CATransitionSubtype.fromLeft
		}
		viewLocal.layer.add(animation, forKey: kCATransition)
	}
	
	// Currently not used
	func showErrorDataChannelNotReady() {
		
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCATransitionType(_ input: String) -> CATransitionType {
	return CATransitionType(rawValue: input)
}
