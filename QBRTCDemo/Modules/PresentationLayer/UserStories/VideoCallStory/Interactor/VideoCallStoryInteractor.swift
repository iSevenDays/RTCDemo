//
//  VideoCallStoryInteractor.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class VideoCallStoryInteractor: NSObject {

    weak var output: VideoCallStoryInteractorOutput?
	
	var callService: (CallServiceProtocol & CallServiceCameraSwitcherProtocol)!
	var pushService: PushNotificationsServiceProtocol!
	var permissionsService: PermissionsServiceProtocol!
	
	var localVideoTrack: RTCVideoTrack?
	var localAudioTrack: RTCAudioTrack?
	
	var remoteVideoTrack: RTCVideoTrack?
	var connectingToChat = false
	var opponent: SVUser?
	var audioSessionPortOverride: AVAudioSession.PortOverride = .speaker
	
	var currentUser: SVUser? {
		return callService.currentUser
	}
	
	var isReadyForDataChannel: Bool {
		return false
		//return callService.dataChannelEnabled && callService.isDataChannelReady()
	}
	
	// MARK: - Enable/disable local video track
	
	internal func isLocalAudioTrackEnabled() -> Bool {
		return localAudioTrack?.isEnabled ?? false
	}
	
	internal func isLocalVideoTrackEnabled() -> Bool {
		return localVideoTrack?.isEnabled ?? false
	}
	
	internal func enableLocalVideoTrack() {
		localVideoTrack?.isEnabled = true
	}
	
	internal func disableLocalVideoTrack() {
		localVideoTrack?.isEnabled = false
	}
	
	internal func enableLocalAudioTrack() {
		localAudioTrack?.isEnabled = true
	}
	
	internal func disableLocalAudioTrack() {
		localAudioTrack?.isEnabled = false
	}
}

extension VideoCallStoryInteractor: VideoCallStoryInteractorInput {
	func startCallWithOpponent(_ opponent: SVUser) {
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
	
	func acceptCallFromOpponent(_ opponent: SVUser) {
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
		
		RTCDispatcher.dispatchAsync(on: .typeAudioSession) { [unowned self] in
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
		guard let localVideoTrack = self.localVideoTrack else {
			return
		}
		if NSClassFromString("XCTest") != nil {
			// We should not received nil localVideoTrack without granted permissions
			output?.willSwitchDevicePositionWithConfigurationBlock({ [weak self] (renderer) in
				guard let `self` = self else { return }
				self.output?.didSwitchCameraPosition(true)
			})
			return
		}
		output?.willSwitchDevicePositionWithConfigurationBlock({ (renderer) in
			guard let rendererView = renderer else {
				return
			}
			guard let newPosition = self.callService.switchCamera(forActivePeerConnectionWithLocalVideoTrack: localVideoTrack, renderer: rendererView) else {
				// TODO: pass error
				return
			}

			self.output?.didSwitchCameraPosition(newPosition == .back)
		})
	}
	
	// MARK: - Switch audio route
	func switchAudioRoute() {
		var desiredRoute = AVAudioSession.PortOverride.none
		if audioSessionPortOverride == desiredRoute {
			desiredRoute = .speaker
		}
		RTCDispatcher.dispatchAsync(on: .typeAudioSession) { [unowned self] in
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
	func callService(_ callService: CallServiceProtocol, didReceiveLocalAudioTrack localAudioTrack: RTCAudioTrack) {
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
	
	func callService(_ callService: CallServiceProtocol, didReceiveHangupFromOpponent opponent: SVUser) {
		guard let currentOpponent = self.opponent else {
			return
		}
		guard currentOpponent == opponent else {
			return
		}
		output?.didReceiveHangupFromOpponent(opponent)
	}
	
	func callService(_ callService: CallServiceProtocol, didReceiveRejectFromOpponent opponent: SVUser) {
		output?.didReceiveRejectFromOpponent(opponent)
	}

	func callService(_ callService: CallServiceProtocol, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {

		guard self.localVideoTrack != localVideoTrack else {
			NSLog("Warning: Received the same local video track")
			return
		}
		self.localVideoTrack = localVideoTrack

		if NSClassFromString("XCTest") != nil {
			// We should not received nil localVideoTrack without granted permissions
			if permissionsService.authorizationStatusForVideo() == .authorized {
				output?.didReceiveLocalVideoTrackWithConfigurationBlock({ [weak self] (renderer) in
					guard let `self` = self else { return }
					self.localVideoTrack = localVideoTrack
					self.output?.didSwitchLocalVideoTrackState(true)

				})
			}
			return
		}

		output?.didReceiveLocalVideoTrackWithConfigurationBlock({ [weak self] (renderer) in
			guard let `self` = self else { return }

			self.localVideoTrack = nil
			self.localVideoTrack = localVideoTrack

			if let renderer = renderer {
				self.callService.setCamera(forActivePeerConnectionWithLocalVideoTrack: localVideoTrack, renderer: renderer, position: .front)
				// called automatically - strongSelf.localVideoTrack?.add(renderer)

				self.output?.didSwitchLocalVideoTrackState(true)
			} else if NSClassFromString("XCTest") == nil {
				fatalError("Error - failed to get renderer")
			}
		})


		// TODO: consider removing all calls to didSetLocalCaptureSession
		//source.session
		//		if let session = source?.captureSession {
		//			output?.didSetLocalCaptureSession(session)
		//			output?.didSwitchLocalVideoTrackState(true)
		//		} else {
		//			output?.didSwitchLocalVideoTrackState(false)
		//		}
	}
	
	func callService(_ callService: CallServiceProtocol, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
		
		//DDLogVerbose(@"Call service %@ didReceiveRemoteVideoTrack: %@", callService,  remoteVideoTrack);
		
		output?.didReceiveRemoteVideoTrackWithConfigurationBlock { [weak self] (renderer) in
			guard let strongSelf = self else { return }
			guard strongSelf.remoteVideoTrack != remoteVideoTrack else { return }

			strongSelf.remoteVideoTrack = nil
			strongSelf.remoteVideoTrack = remoteVideoTrack

			if let renderer = renderer {
				strongSelf.remoteVideoTrack?.add(renderer)
			} else if NSClassFromString("XCTest") == nil {
				fatalError("Error - failed to get renderer")
			}
		}
	}
	
	func callService(_ callService: CallServiceProtocol, didReceiveCallRequestFromOpponent opponent: SVUser) {
		// do nothing
	}
	
	func callService(_ callService: CallServiceProtocol, didAnswerTimeoutForOpponent opponent: SVUser) {
		output?.didReceiveAnswerTimeoutForOpponent(opponent)
	}
	
	func callService(_ callService: CallServiceProtocol, didChangeConnectionState state: RTCIceConnectionState) {
		
	}
	
	func callService(_ callService: CallServiceProtocol, didChangeState state: CallServiceState) {
		if state == CallServiceState.error {
			output?.didFailCallService()
		}
	}
	
	func callService(_ callService: CallServiceProtocol, didStartDialingOpponent opponent: SVUser) {
		output?.didStartDialingOpponent(opponent)
		
		guard let currentUserFullName = self.currentUser?.fullName else { return }
		pushService.sendPushNotificationMessage("\(currentUserFullName) is calling you", toOpponent: opponent)
		output?.didSendPushNotificationAboutNewCallToOpponent(opponent)
	}
	
	func callService(_ callService: CallServiceProtocol, didReceiveAnswerFromOpponent opponent: SVUser) {
		setupDefaultAudioSessionPort()
		output?.didReceiveAnswerFromOpponent(opponent)
	}  
	
	func callService(_ callService: CallServiceProtocol, didError error: Error) {
		
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
