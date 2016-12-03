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
	@IBOutlet weak var btnStartCall: UIButton!
	@IBOutlet weak var btnOpenDataChannel: UIButton!
	@IBOutlet weak var btnHangup: UIButton!
	@IBOutlet weak var lblConnected: UILabel!
	@IBOutlet weak var lblState: UILabel!
	@IBOutlet weak var lblIceState: UILabel!
	@IBOutlet weak var viewRemote: RTCEAGLVideoView!
	@IBOutlet weak var viewLocal: RTCCameraPreviewView!
	
	
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }
	
	// MARK: - IBActions
	
	func didTapButtonHangup(sender: UIButton) {
		output.didTriggerHangupButtonTapped()
	}
	
	func didTapButtonDataChannelImageGallery(sender: UIButton) {
		output.didTriggerDataChannelButtonTapped()
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
