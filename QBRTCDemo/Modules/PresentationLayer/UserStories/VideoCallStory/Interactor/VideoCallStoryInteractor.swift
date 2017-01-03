//
//  VideoCallStoryInteractor.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class VideoCallStoryInteractor: NSObject {

    weak var output: VideoCallStoryInteractorOutput?
	
	var callService: CallServiceProtocol!
	var pushService: PushNotificationsServiceProtocol!
	
	var localVideoTrack: RTCVideoTrack?
	var remoteVideoTrack: RTCVideoTrack?
	var connectingToChat = false
	var opponent: SVUser?
	var audioSessionPortOverride: AVAudioSessionPortOverride = .None
	
	var currentUser: SVUser? {
		return callService.currentUser
	}
	
	var isReadyForDataChannel: Bool {
		return false
		//return callService.dataChannelEnabled && callService.isDataChannelReady()
	}
	
	// MARK: - Enable/disable local video track
	
	internal func isLocalVideoTrackEnabled() -> Bool {
		return localVideoTrack?.isEnabled() ?? false
	}
	
	internal func enableLocalVideoTrack() {
		localVideoTrack?.setEnabled(true)
	}
	
	internal func disableLocalVideoTrack() {
		localVideoTrack?.setEnabled(false)
	}
}

extension VideoCallStoryInteractor: VideoCallStoryInteractorInput {
	func startCallWithOpponent(opponent: SVUser) {
		guard callService.isConnected else {
			NSLog("Error: not connected to chat")
			return
		}
		
		guard !callService.hasActiveCall else {
			NSLog("Error: Can not call while already connecting");
			return
		}
		
		self.opponent = opponent
		callService.addObserver(self)
		
		//DDLogInfo(@"Starting a call with opponent %@", opponent);
		do {
			try callService.startCallWithOpponent(opponent)
		} catch CallServiceError.notLogined {
			NSLog("%@", "Error call service is not connected to chat")
		} catch let error {
			NSLog("%@", "Error starting a call with user \(error)")
		}
	}
	
	func acceptCallFromOpponent(opponent: SVUser) {
		self.opponent = opponent
		callService.addObserver(self)
		do {
			try callService.acceptCallFromOpponent(opponent)
		} catch CallServiceError.noPendingOfferForOpponent {
			NSLog("%@", "Error call service can not accept call because there is no pending offer for the call")
			output?.didFailCallService()
		} catch let error {
			NSLog("%@", "Error starting a call with user \(error)")
		}
	}
	
	func sendInvitationMessageAndOpenImageGallery() {
//		if callService.sendText(DataChannelMessages.invitationToOpenImageGallery()) {
//			output.didSendInvitationToOpenImageGallery()
//		}
	}
	
	func hangup() {
		if !callService.hasActiveCall {
			NSLog("Warning: There is no active call at the momment, can not hangup");
		}
		callService.hangup()
		localVideoTrack = nil
		remoteVideoTrack = nil
		output?.didHangup()
	}
	
	func requestDataChannelState() {
		if isReadyForDataChannel {
			output?.didReceiveDataChannelStateReady()
		} else {
			output?.didReceiveDataChannelStateNotReady()
		}
	}
	
	// MARK: - Switch camera
	func switchCamera() {
		if let videoSource = localVideoTrack?.source as? RTCAVFoundationVideoSource {
			videoSource.useBackCamera = !videoSource.useBackCamera
		}
	}
	
	// MARK: - Switch audio route
	func switchAudioRoute() {
		var desiredRoute = AVAudioSessionPortOverride.None
		if audioSessionPortOverride == desiredRoute {
			desiredRoute = .Speaker
		}
		RTCDispatcher.dispatchAsyncOnType(.TypeAudioSession) { [unowned self] in
			let session = RTCAudioSession.sharedInstance()
			
			do {
				session.lockForConfiguration()
				defer { session.unlockForConfiguration() }
				try session.overrideOutputAudioPort(desiredRoute)
				
				self.audioSessionPortOverride = desiredRoute
			} catch let error {
				NSLog("%@", "Error overriding output port: \(error)")
			}
		}
	}
	
	// MARK: - Enable / disable sending a local video track
	func switchLocalVideoTrackState() {
		let localVideoTrackEnabled = isLocalVideoTrackEnabled()
		
		if localVideoTrackEnabled {
			disableLocalVideoTrack()
		} else {
			enableLocalVideoTrack()
		}
		
		output?.didChangeLocalVideoTrackState(isLocalVideoTrackEnabled())
	}
}

extension VideoCallStoryInteractor: CallServiceObserver {
	func callService(callService: CallServiceProtocol, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {
		guard NSClassFromString("XCTest") == nil else {
			self.localVideoTrack = localVideoTrack
			output?.didSetLocalCaptureSession(AVCaptureSession())
			output?.didChangeLocalVideoTrackState(true)
			return
		}
		
		guard self.localVideoTrack != localVideoTrack else {
			NSLog("Warning: Received the same local video track")
			return
		}
		self.localVideoTrack = localVideoTrack
		
		let source = localVideoTrack.source as? RTCAVFoundationVideoSource
		
		if let session = source?.captureSession {
			output?.didSetLocalCaptureSession(session)
			output?.didChangeLocalVideoTrackState(true)
		} else {
			output?.didChangeLocalVideoTrackState(false)
		}
	}  
	
	func callService(callService: CallServiceProtocol, didReceiveHangupFromOpponent opponent: SVUser) {
		guard let currentOpponent = self.opponent else {
			return
		}
		guard currentOpponent == opponent else {
			return
		}
		output?.didReceiveHangupFromOpponent(opponent)
	}
	
	func callService(callService: CallServiceProtocol, didReceiveRejectFromOpponent opponent: SVUser) {
		output?.didReceiveRejectFromOpponent(opponent)
	}
	
	func callService(callService: CallServiceProtocol, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
		
		//DDLogVerbose(@"Call service %@ didReceiveRemoteVideoTrack: %@", callService,  remoteVideoTrack);
		
		output?.didReceiveRemoteVideoTrackWithConfigurationBlock { [weak self] (renderer) in
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
		output?.didReceiveAnswerTimeoutForOpponent(opponent)
	}
	
	func callService(callService: CallServiceProtocol, didChangeConnectionState state: RTCICEConnectionState) {
		
	}
	
	func callService(callService: CallServiceProtocol, didChangeState state: CallServiceState) {
		if state == CallServiceState.Error {
			output?.didFailCallService()
		}
	}
	
	func callService(callService: CallServiceProtocol, didStartDialingOpponent opponent: SVUser) {
		output?.didStartDialingOpponent(opponent)
		
		guard let currentUserFullName = self.currentUser?.fullName else { return }
		pushService.sendPushNotificationMessage("\(currentUserFullName) is calling you", toOpponent: opponent)
		output?.didSendPushNotificationAboutNewCallToOpponent(opponent)
	}
	
	func callService(callService: CallServiceProtocol, didReceiveAnswerFromOpponent opponent: SVUser) {
		output?.didReceiveAnswerFromOpponent(opponent)
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
