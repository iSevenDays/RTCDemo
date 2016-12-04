//
//  VideoCallStoryViewInput.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

protocol VideoCallStoryViewInput: class {

    /**
        @author Anton Sokolchenko
        Setup initial state of the view
    */
    func setupInitialState()
	
	func configureViewWithUser(user: SVUser)
	
	func showHangup()
	func showOpponentHangup()
	
	func showErrorConnect()
	func showErrorDataChannelNotReady()
	func setLocalVideoCaptureSession(captureSession: AVCaptureSession)
	func configureRemoteVideoViewWithBlock(block: ((RTCEAGLVideoView?) -> Void)?)
}
