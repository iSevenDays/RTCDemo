//
//  PeerConnection.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 09.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation
import WebRTC

protocol PeerConnectionObserver: class {
	func peerConnection(_ peerConnection: PeerConnection, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack)
	func peerConnection(_ peerConnection: PeerConnection, didReceiveLocalAudioTrack localAudioTrack: RTCAudioTrack)
	func peerConnection(_ peerConnection: PeerConnection, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack)
	func peerConnection(_ peerConnection: PeerConnection, didCreateSessionWithError error: Error)
	func peerConnection(_ peerConnection: PeerConnection, didSetLocalICECandidates localICECandidates: RTCIceCandidate)
	
	// User has an offer to send
	func peerConnection(_ peerConnection: PeerConnection, didSetLocalSessionOfferDescription localSessionDescription: RTCSessionDescription)
	
	// User has an answer to send
	func peerConnection(_ peerConnection: PeerConnection, didSetLocalSessionAnswerDescription localSessionDescription: RTCSessionDescription)
}

enum PeerConnectionState {
	case initial
	case closed
}

func SVRTCSignalingState(_ state: RTCSignalingState) -> String {
	switch state {
	case .stable: return "RTCSignalingStable"
	case .haveLocalOffer: return "RTCSignalingHaveLocalOffer"
	case .haveLocalPrAnswer: return "RTCSignalingHaveLocalPrAnswer"
	case .haveRemoteOffer: return "RTCSignalingHaveRemoteOffer"
	case .haveRemotePrAnswer: return "RTCSignalingHaveRemotePrAnswer"
	case .closed: return "RTCSignalingClosed"
	}
}

class PeerConnection: NSObject {
	fileprivate(set) var sessionID: String
	fileprivate(set) var peerConnection: RTCPeerConnection?
	fileprivate(set) var mediaStreamConstraints: RTCMediaConstraints
	fileprivate(set) var peerConnectionConstraints: RTCMediaConstraints
	fileprivate(set) var offerAnswerConstraints: RTCMediaConstraints
	fileprivate(set) var factory: RTCPeerConnectionFactory
	fileprivate(set) var opponent: SVUser
	fileprivate(set) var ICECandidates: [RTCIceCandidate] = []
	fileprivate(set) var ICEServers: [RTCIceServer]
	fileprivate(set) var state = PeerConnectionState.initial
	fileprivate(set) var videoCapturer: RTCVideoCapturer?
	fileprivate(set) var localAudioTrack: RTCAudioTrack?
	fileprivate(set) var localVideoTrack: RTCVideoTrack?
	fileprivate var streamID = "ARDAMS"
	
	fileprivate var observers = MulticastDelegate<PeerConnectionObserver>()
	
	init(opponent: SVUser, sessionID: String, ICEServers: [RTCIceServer], factory: RTCPeerConnectionFactory, mediaStreamConstraints: RTCMediaConstraints, peerConnectionConstraints: RTCMediaConstraints, offerAnswerConstraints: RTCMediaConstraints) {
		self.opponent = opponent
		self.sessionID = sessionID
		self.ICEServers = ICEServers
		self.mediaStreamConstraints = mediaStreamConstraints
		self.peerConnectionConstraints = peerConnectionConstraints
		self.offerAnswerConstraints = offerAnswerConstraints
		self.factory = factory
		super.init()
	}
	
	func addObserver(_ observer: PeerConnectionObserver) {
		observers += observer
	}

	func getRTCConfiguration() -> RTCConfiguration {
		let configuration = RTCConfiguration()
		configuration.iceServers = ICEServers
		configuration.sdpSemantics = .unifiedPlan
		return configuration
	}
	
	func startCall() {
		let configuration = getRTCConfiguration()
		
		peerConnection = factory.peerConnection(with: configuration, constraints: peerConnectionConstraints, delegate: self)
		peerConnection?.delegate = self
		createMediaSenders()
		
		// Send offer.
		peerConnection?.offer(for: offerAnswerConstraints, completionHandler: { [weak self] (sdp, error) in
			guard let strongSelf = self else { return }
			
			if let error = error {
				NSLog("%@", "Error failed to set local offer \(error)")
				strongSelf.observers |> { $0.peerConnection(strongSelf, didCreateSessionWithError: error) }
				return
			}
			
			guard let sessionDescription = sdp else {
				NSLog("%@", "Error SDP Offer is nil")
				return
			}
			
			let sdpPreferringH264 = WebRTCHelpers.description(for: sessionDescription, preferredVideoCodec: "H264")
			let sdpModifiedBandWidth = WebRTCHelpers.constrainedSessionDescription(sdpPreferringH264, videoBandwidth: 6000, audioBandwidth: 6000)
			strongSelf.peerConnection?.setLocalDescription(sdpModifiedBandWidth!, completionHandler: { (error) in
				if let error = error {
					NSLog("%@", "Error setLocalDescription \(error)")
					strongSelf.observers |> { $0.peerConnection(strongSelf, didCreateSessionWithError: error) }
					return
				}
				guard let peerConnection = strongSelf.peerConnection else {
					NSLog("Error - no peer connection")
					return
				}
				strongSelf.observers |> { $0.peerConnection(strongSelf, didSetLocalSessionOfferDescription: peerConnection.localDescription!) }
			})
			})
	}
	
	func acceptCall() {
		let configuration = getRTCConfiguration()
		peerConnection = factory.peerConnection(with: configuration, constraints: peerConnectionConstraints, delegate: self)
		peerConnection?.delegate = self
		
		// Create AV media stream and add it to the peer connection.
		createMediaSenders()
	}
	
	func close() {
		state = .closed
		peerConnection?.delegate = nil
		if let localStreams = peerConnection?.localStreams {
			for stream in localStreams {
				peerConnection?.remove(stream)
			}
		}
		peerConnection?.close()
		peerConnection = nil
		ICECandidates.removeAll()
	}
	
	// Processing incoming events from opponent
	func applyRemoteSDP(_ sdp: RTCSessionDescription) {
		NSLog("Received remote SDP for opponent \(opponent)")
		peerConnection?.setRemoteDescription(sdp, completionHandler: { [weak self] (error) in
			guard let strongSelf = self else { return }
			if let error = error {
				NSLog("%@", "Error failed to set remote offer \(error)")
				strongSelf.observers |> { $0.peerConnection(strongSelf, didCreateSessionWithError: error) }
				return
			}
			
			guard sdp.type == .offer else { return }
			// We cannot create an answer for an answer
			
			strongSelf.peerConnection!.answer(for: strongSelf.offerAnswerConstraints, completionHandler: { (sdpAnswer, error) in
				if let error = error {
					NSLog("%@", "Error failed to create offer \(error)")
					strongSelf.observers |> { $0.peerConnection(strongSelf, didCreateSessionWithError: error) }
					return
				}
				guard let sessionDescription = sdpAnswer else {
					NSLog("%@", "Error SDP Answer is nil")
					return
				}
				strongSelf.peerConnection?.setLocalDescription(sessionDescription, completionHandler: { (error) in
					if let error = error {
						NSLog("%@", "Error failed to set local description \(error)")
						strongSelf.observers |> { $0.peerConnection(strongSelf, didCreateSessionWithError: error) }
						return
					}
					
					if strongSelf.state != .closed {
						// RTCSignalingStable means that we applied remote offer SDP, created answer, applied local SDP
						// and now local SPD has been set
						strongSelf.observers |> { $0.peerConnection(strongSelf, didSetLocalSessionAnswerDescription: strongSelf.peerConnection!.localDescription!) }
					}
				})
			})
			})
	}
	
	func applyICECandidates(_ ICECandidates: [RTCIceCandidate]) {
		for candidate in ICECandidates {
			peerConnection?.add(candidate)
		}
	}

	func createMediaSenders() {
		let localVideoTrack = createLocalVideoTrack()
		self.localVideoTrack = localVideoTrack

		let localAudioTrack = createLocalAudioTrack()
		self.localAudioTrack = localAudioTrack
		peerConnection?.add(localAudioTrack, streamIds: [streamID])

		observers |> {$0.peerConnection(self, didReceiveLocalAudioTrack: localAudioTrack)}

		peerConnection?.add(localVideoTrack, streamIds: [streamID])

		observers |> {$0.peerConnection(self, didReceiveLocalVideoTrack: localVideoTrack)}

		// We can set up rendering for the remote track right away since the transceiver already has an
		// RTCRtpReceiver with a track. The track will automatically get unmuted and produce frames
		// once RTP is received.
		if let remoteVideoTrack = videoTransceiver()?.receiver.track as? RTCVideoTrack {
			observers |> {$0.peerConnection(self, didReceiveRemoteVideoTrack: remoteVideoTrack)}
		}
	}
}

extension PeerConnection: RTCPeerConnectionDelegate {
	func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
		let signalingState = SVRTCSignalingState(stateChanged)
		NSLog("Signaling state changed: \(signalingState)");
	}

	func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
		NSLog("Received \(stream.videoTracks.count) video tracks and \(stream.audioTracks.count) audio tracks");
		if let videoTrack = stream.videoTracks.first {
			observers |> {$0.peerConnection(self, didReceiveRemoteVideoTrack: videoTrack)}
		}
	}
	func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
		NSLog("Candidates removed")
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
		NSLog("Stream removed")
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
		if newState == .failed {
			NSLog("ICE connection failed")
		}
	}
	func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
		
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
		// TODO: make a queue and send when local ICE candidates have been collected
		ICECandidates += candidate
		observers |> { $0.peerConnection(self, didSetLocalICECandidates: candidate) }
		ICECandidates.removeAll()
	}
	
	func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
		
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
		
	}
	
	func peerConnection(_ peerConnection: RTCPeerConnection, didRemovedidRemove candidates: [RTCIceCandidate]) {
		
	}
	
	
}

// MARK: - Creating local media stream
private extension PeerConnection {

	func videoTransceiver() -> RTCRtpTransceiver? {
		for transceiver in peerConnection?.transceivers ?? [] {
			if transceiver.mediaType == .video {
				return transceiver
			}
		}
		return nil
	}

	func createLocalAudioTrack() -> RTCAudioTrack {
		let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
		let audioSource = factory.audioSource(with: audioConstrains)
		let audioTrack = factory.audioTrack(with: audioSource, trackId: "audio0")
		return audioTrack
	}
	
	func createLocalVideoTrack() -> RTCVideoTrack {
		let videoSource = factory.videoSource()
		#if TARGET_OS_SIMULATOR
			self.videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
		#else
			self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
		#endif
		let localVideoTrack = factory.videoTrack(with: videoSource, trackId: "video0")
		return localVideoTrack
	}
}

extension PeerConnection {
	func startCaptureLocalVideo(renderer: RenderableView, position: AVCaptureDevice.Position) {
		guard let capturer = self.videoCapturer as? RTCCameraVideoCapturer else {
			NSLog("Error getting camera capturer")
			return
		}

		guard
			let cameraForPosition = (RTCCameraVideoCapturer.captureDevices().first { $0.position == position }),

			// choose highest res
			let format = (RTCCameraVideoCapturer.supportedFormats(for: cameraForPosition).sorted { (f1, f2) -> Bool in
				let width1 = CMVideoFormatDescriptionGetDimensions(f1.formatDescription).width
				let width2 = CMVideoFormatDescriptionGetDimensions(f2.formatDescription).width
				return width1 < width2
			}).last,

			// choose highest fps
			let fps = (format.videoSupportedFrameRateRanges.sorted { return $0.maxFrameRate < $1.maxFrameRate }.last) else {
				return
		}

		capturer.startCapture(with: cameraForPosition,
							  format: format,
							  fps: Int(fps.maxFrameRate))

		self.localVideoTrack?.add(renderer)
	}

	func localVideoCapturePosition() -> AVCaptureDevice.Position? {
		guard let capturer = videoCapturer as? RTCCameraVideoCapturer else {
			return nil
		}
		guard let firstInput = capturer.captureSession.inputs.first as? AVCaptureDeviceInput else {
			return nil
		}

		return firstInput.device.position
	}
}
