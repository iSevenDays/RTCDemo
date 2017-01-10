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
	var permissionsService: PermissionsServiceProtocol!
	
	var localVideoTrack: RTCVideoTrack?
	var localAudioTrack: RTCAudioTrack?
	
	var remoteVideoTrack: RTCVideoTrack?
	var connectingToChat = false
	var opponent: SVUser?
	var audioSessionPortOverride: AVAudioSessionPortOverride = .Speaker
	
	var currentUser: SVUser? {
		return callService.currentUser
	}
	
	var isReadyForDataChannel: Bool {
		return false
		//return callService.dataChannelEnabled && callService.isDataChannelReady()
	}
	
	// MARK: - Enable/disable local video track
	
	internal func isLocalAudioTrackEnabled() -> Bool {
		return localAudioTrack?.isEnabled() ?? false
	}
	
	internal func isLocalVideoTrackEnabled() -> Bool {
		return localVideoTrack?.isEnabled() ?? false
	}
	
	internal func enableLocalVideoTrack() {
		localVideoTrack?.setEnabled(true)
	}
	
	internal func disableLocalVideoTrack() {
		localVideoTrack?.setEnabled(false)
	}
	
	internal func enableLocalAudioTrack() {
		localAudioTrack?.setEnabled(true)
	}
	
	internal func disableLocalAudioTrack() {
		localAudioTrack?.setEnabled(false)
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
		
		setupDefaultAudioSessionPort()
	}
	
	func setupDefaultAudioSessionPort() {
		var desiredRoute = audioSessionPortOverride
		
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
		guard permissionsService.authorizationStatusForVideo() == .authorized else {
			output?.didReceiveVideoStatusDenied()
			return
		}
		
		if let videoSource = localVideoTrack?.source as? RTCAVFoundationVideoSource {
			videoSource.useBackCamera = !videoSource.useBackCamera
			output?.didSwitchCameraPosition(videoSource.useBackCamera)
		} else if NSClassFromString("XCTest") != nil {
			// We should not received nil localVideoTrack without granted permissions
			output?.didSwitchCameraPosition(true)
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
		guard permissionsService.authorizationStatusForVideo() == .authorized else {
			output?.didReceiveVideoStatusDenied()
			return
		}
		let localVideoTrackEnabled = isLocalVideoTrackEnabled()
		
		if localVideoTrackEnabled {
			disableLocalVideoTrack()
		} else {
			enableLocalVideoTrack()
		}
		
		output?.didSwitchLocalVideoTrackState(isLocalVideoTrackEnabled())
	}
	
	// MARK: - Permissions
	func requestVideoPermissionStatus() {
		let authStatus = permissionsService.authorizationStatusForVideo()
		switch authStatus {
		case .authorized: output?.didReceiveVideoStatusAuthorized()
		case .denied: output?.didReceiveVideoStatusDenied()
		case .notDetermined:
			permissionsService.requestAccessForVideo({ [output] (granted) in
				if granted {
					output?.didReceiveVideoStatusAuthorized()
				} else {
					output?.didReceiveVideoStatusDenied()
				}
				})
		}
	}
	
	func switchLocalAudioTrackState() {
		guard permissionsService.authorizationStatusForMicrophone() == .authorized else {
			output?.didReceiveMicrophoneStatusDenied()
			return
		}
		let localAudioTrackEnabled = isLocalAudioTrackEnabled()
		
		if localAudioTrackEnabled {
			disableLocalAudioTrack()
		} else {
			enableLocalAudioTrack()
		}
		
		output?.didSwitchLocalAudioTrackState(isLocalAudioTrackEnabled())
	}
	
	func requestMicrophonePermissionStatus() {
		let authStatus = permissionsService.authorizationStatusForMicrophone()
		switch authStatus {
		case .authorized: output?.didReceiveMicrophoneStatusAuthorized()
		case .denied: output?.didReceiveMicrophoneStatusDenied()
		case .notDetermined:
			permissionsService.requestAccessForMicrophone({ [output] (granted) in
				if granted {
					output?.didReceiveMicrophoneStatusAuthorized()
				} else {
					output?.didReceiveMicrophoneStatusDenied()
				}
				})
		}
	}
}

extension VideoCallStoryInteractor: CallServiceObserver {
	func callService(callService: CallServiceProtocol, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {
		if NSClassFromString("XCTest") != nil {
			// We should not received nil localVideoTrack without granted permissions
			if permissionsService.authorizationStatusForVideo() == .authorized {
				self.localVideoTrack = localVideoTrack
				output?.didSetLocalCaptureSession(AVCaptureSession())
				output?.didSwitchLocalVideoTrackState(true)
			}
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
			output?.didSwitchLocalVideoTrackState(true)
		} else {
			output?.didSwitchLocalVideoTrackState(false)
		}
	}
	
	func callService(callService: CallServiceProtocol, didReceiveLocalAudioTrack localAudioTrack: RTCAudioTrack) {
		if NSClassFromString("XCTest") != nil {
			// We should not received nil localVideoTrack without granted permissions
			if permissionsService.authorizationStatusForMicrophone() == .authorized {
				self.localAudioTrack = localAudioTrack
				output?.didSwitchLocalAudioTrackState(true)
			}
			return
		}
		
		guard self.localAudioTrack != localAudioTrack else {
			NSLog("Warning: Received the same local audio track")
			return
		}
		self.localAudioTrack = localAudioTrack
		if permissionsService.authorizationStatusForMicrophone() == .authorized {
			output?.didSwitchLocalAudioTrackState(true)
		} else {
			output?.didSwitchLocalAudioTrackState(false)
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
		setupDefaultAudioSessionPort()
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
