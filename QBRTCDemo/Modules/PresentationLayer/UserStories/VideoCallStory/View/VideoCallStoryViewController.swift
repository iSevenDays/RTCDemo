//
//  VideoCallStoryViewController.swift
//  QBRTCDemo
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
	
	func showOpponentHangup() {
		output.didTriggerCloseButtonTapped()
	}
	
	func showErrorConnect() {
		
	}
	
	func showErrorDataChannelNotReady() {
		
	}
	
	func setLocalVideoCaptureSession(captureSession: AVCaptureSession) {
		loadViewIfNeeded()
		viewLocal.captureSession = captureSession
	}
	
	func configureRemoteVideoViewWithBlock(block: ((RTCEAGLVideoView?) -> Void)?) {
		block?(viewRemote)
	}
}
