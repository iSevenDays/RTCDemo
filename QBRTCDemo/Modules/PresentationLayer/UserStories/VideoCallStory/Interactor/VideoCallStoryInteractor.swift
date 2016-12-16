//
//  VideoCallStoryInteractor.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class VideoCallStoryInteractor: NSObject {

    weak var output: VideoCallStoryInteractorOutput!
	
	var callService: CallServiceProtocol!
	var pushService: PushNotificationsServiceProtocol!
	
	var localVideoTrack: RTCVideoTrack?
	var remoteVideoTrack: RTCVideoTrack?
	var connectingToChat = false
	var lastOpponent: SVUser?
	var audioSessionPortOverride: AVAudioSessionPortOverride = .None
	
	var currentUser: SVUser? {
		return callService.currentUser
	}
	
	var isReadyForDataChannel: Bool {
		return false
		//return callService.dataChannelEnabled && callService.isDataChannelReady()
	}
}

extension VideoCallStoryInteractor: VideoCallStoryInteractorInput {
	func connectToChatWithUser(user: SVUser, callOpponent opponent: SVUser?) {
		guard !callService.isConnecting else {
			return
		}
		
		callService.addObserver(self)
		
		let connectWithUserAndCallOpponent = { [weak self] in
			guard let strongSelf = self else { return }
			
			strongSelf.callService.connectWithUser(user, completion: { (error) in
				guard error == nil else {
					strongSelf.output.didFailToConnectToChat()
					return
				}
				strongSelf.output.didConnectToChatWithUser(user)
				if let opponent = opponent {
					strongSelf.startCallWithOpponent(opponent)
				}
			})
		}
		
		
		if callService.isConnected && currentUser == user {
			if let opponent = opponent {
				startCallWithOpponent(opponent)
			}
		} else if callService.isConnected && currentUser != user {
			NSLog("Connected with another user, doing disconnect")
			callService.disconnectWithCompletion({ [weak output] (error) in
				guard error == nil else {
					NSLog("%@", "Error disconnecting \(error)")
					output?.didFailToConnectToChat() // TODO: fix new method add
					return
				}
				connectWithUserAndCallOpponent()
				})
		} else {
			connectWithUserAndCallOpponent()
		}
	}
	
	func startCallWithOpponent(opponent: SVUser) {
		guard !callService.hasActiveCall else {
			NSLog("Error: Can not call while already connecting");
			return
		}
		
		lastOpponent = opponent
		callService.addObserver(self)
		
		//DDLogInfo(@"Starting a call with opponent %@", opponent);
		do {
			try callService.startCallWithOpponent(opponent)
		}
		catch let error {
			NSLog("%@", "Error starting a call with user \(error)")
		}
	}
	
	func acceptCallFromOpponent(opponent: SVUser) {
		lastOpponent = opponent
		callService.addObserver(self)
		callService.acceptCallFromOpponent(opponent)
	}
	
	func sendInvitationMessageAndOpenImageGallery() {
//		if callService.sendText(DataChannelMessages.invitationToOpenImageGallery()) {
//			output.didSendInvitationToOpenImageGallery()
//		}
	}
	
	func hangup() {
		guard callService.hasActiveCall else {
			NSLog("There is no active call at the momment, can not hangup");
			return
		}
		callService.hangup()
		localVideoTrack = nil
		remoteVideoTrack = nil
		output.didHangup()
	}
	
	func requestDataChannelState() {
		if isReadyForDataChannel {
			output.didReceiveDataChannelStateReady()
		} else {
			output.didReceiveDataChannelStateNotReady()
		}
	}
	
	/// MARK: - Switch camera
	func switchCamera() {
		if let videoSource = localVideoTrack?.source as? RTCAVFoundationVideoSource {
			videoSource.useBackCamera = !videoSource.useBackCamera
		}
	}
	
	/// MARK: - Switch audio route
	func switchAudioRoute() {
		var desiredRoute = AVAudioSessionPortOverride.None
		if audioSessionPortOverride == desiredRoute {
			desiredRoute = .Speaker
		}
		RTCDispatcher.dispatchAsyncOnType(.TypeAudioSession) { [unowned self] in
			let session = RTCAudioSession.sharedInstance()
			session.lockForConfiguration()
			do {
				try session.overrideOutputAudioPort(desiredRoute)
				self.audioSessionPortOverride = desiredRoute
			} catch let error {
				NSLog("%@", "Error overriding output port: \(error)")
			}
			session.unlockForConfiguration()
		}
	}
}

extension VideoCallStoryInteractor: CallServiceObserver {
	func callService(callService: CallServiceProtocol, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {
		if NSClassFromString("XCTest") != nil {
			output.didSetLocalCaptureSession(AVCaptureSession())
		}
		
		guard self.localVideoTrack != localVideoTrack else {
			NSLog("Warning: Received the same local video track")
			return
		}
		self.localVideoTrack = localVideoTrack
		
		let source = localVideoTrack.source as? RTCAVFoundationVideoSource
		
		if let source = source {
			if source.captureSession != nil {
				output.didSetLocalCaptureSession(source.captureSession)
			}
		}
	}
	
	func callService(callService: CallServiceProtocol, didReceiveHangupFromOpponent opponent: SVUser) {
		output.didReceiveHangupFromOpponent(opponent)
	}
	
	func callService(callService: CallServiceProtocol, didReceiveRejectFromOpponent opponent: SVUser) {
		output.didReceiveRejectFromOpponent(opponent)
	}
	
	func callService(callService: CallServiceProtocol, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
		
		//DDLogVerbose(@"Call service %@ didReceiveRemoteVideoTrack: %@", callService,  remoteVideoTrack);
		
		output.didReceiveRemoteVideoTrackWithConfigurationBlock { [weak self] (renderer) in
			guard let strongSelf = self else { return }
			guard strongSelf.remoteVideoTrack != remoteVideoTrack else { return }
			
			strongSelf.remoteVideoTrack?.removeRenderer(nil)
			strongSelf.remoteVideoTrack = nil
			
			//TODO: FIX and uncomment: renderer?.renderFrame(nil)
			
			strongSelf.remoteVideoTrack = remoteVideoTrack
			
			strongSelf.remoteVideoTrack?.addRenderer(renderer)
		}
	}
	
	func callService(callService: CallServiceProtocol, didReceiveCallRequestFromOpponent opponent: SVUser) {
		// do nothing
	}
	
	func callService(callService: CallServiceProtocol, didAnswerTimeoutForOpponent opponent: SVUser) {
		output.didReceiveAnswerTimeoutForOpponent(opponent)
	}
	
	func callService(callService: CallServiceProtocol, didChangeConnectionState state: RTCICEConnectionState) {
		
	}
	
	func callService(callService: CallServiceProtocol, didChangeState state: CallServiceState) {
		if state == CallServiceState.Error {
			output.didFailCallService()
		}
	}
	
	func callService(callService: CallServiceProtocol, didStartDialingOpponent opponent: SVUser) {
		guard let currentUserFullName = self.currentUser?.fullName else { return }
		
		pushService.sendPushNotificationMessage("\(currentUserFullName) is calling you", toOpponent: opponent)
		output.didSendPushNotificationAboutNewCallToOpponent(opponent)
	}
	
	func callService(callService: CallServiceProtocol, didError error: NSError) {
		
	}
}
//
//extension VideoCallStoryInteractor: CallServiceDataChannelAdditionsDelegate {
//	func callService(callService: CallServiceProtocol!, didOpenDataChannel dataChannel: RTCDataChannel!) {
//		output.didOpenDataChannel()
//	}
//	
//	func callService(callService: CallServiceProtocol!, didReceiveMessage message: String!) {
//		//DDLogVerbose(@"callService %@ didReceiveMessage %@", callService, message);
//		if message == DataChannelMessages.invitationToOpenImageGallery() {
//			//DDLogInfo(@"received invitation to open image gallery");
//			output.didReceiveInvitationToOpenImageGallery()
//		}
//	}
//}
