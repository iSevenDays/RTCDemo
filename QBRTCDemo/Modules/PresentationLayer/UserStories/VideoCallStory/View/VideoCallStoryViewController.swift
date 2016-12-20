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
	
	@IBAction func didTapButtonSwitchAudioRoute(sender: DesignableButton) {
		sender.selected = !sender.selected
		output.didTriggerSwitchAudioRouteButtonTapped()
	}
}

extension VideoCallStoryViewController: VideoCallStoryViewInput {
	func setupInitialState() {
	}
	
	func configureViewWithUser(user: SVUser) {
		
	}
	
	func showHangup() {
		output.didTriggerCloseButtonTapped()
	}
	
	func showOpponentReject() {
		output.didTriggerCloseButtonTapped()
	}
	
	func showOpponentHangup() {
		output.didTriggerCloseButtonTapped()
	}
	
	func showOpponentAnswerTimeout() {
		output.didTriggerCloseButtonTapped()
	}
	
	func showErrorConnect() {
		
	}
	
	func showErrorCallServiceDisconnected() {
		output.didTriggerCloseButtonTapped()
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
