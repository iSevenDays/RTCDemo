//
//  PeerConnection.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 09.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

protocol PeerConnectionObserver: class {
	func peerConnection(peerConnection: PeerConnection, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack)
	func peerConnection(peerConnection: PeerConnection, didReceiveLocalAudioTrack localAudioTrack: RTCAudioTrack)
	func peerConnection(peerConnection: PeerConnection, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack)
	func peerConnection(peerConnection: PeerConnection, didCreateSessionWithError error: NSError)
	func peerConnection(peerConnection: PeerConnection, didSetLocalICECandidates localICECandidates: RTCIceCandidate)
	
	// User has an offer to send
	func peerConnection(peerConnection: PeerConnection, didSetLocalSessionOfferDescription localSessionDescription: RTCSessionDescription)
	
	// User has an answer to send
	func peerConnection(peerConnection: PeerConnection, didSetLocalSessionAnswerDescription localSessionDescription: RTCSessionDescription)
}

enum PeerConnectionState {
	case Initial
	case Closed
}

func SVRTCSignalingState(state: RTCSignalingState) -> String {
	switch state {
	case .Stable: return "RTCSignalingStable"
	case .HaveLocalOffer: return "RTCSignalingHaveLocalOffer"
	case .HaveLocalPrAnswer: return "RTCSignalingHaveLocalPrAnswer"
	case .HaveRemoteOffer: return "RTCSignalingHaveRemoteOffer"
	case .HaveRemotePrAnswer: return "RTCSignalingHaveRemotePrAnswer"
	case .Closed: return "RTCSignalingClosed"
	}
}

class PeerConnection: NSObject {
	private(set) var sessionID: String
	private(set) var peerConnection: RTCPeerConnection?
	private(set) var mediaStreamConstraints: RTCMediaConstraints
	private(set) var peerConnectionConstraints: RTCMediaConstraints
	private(set) var offerAnswerConstraints: RTCMediaConstraints
	private(set) var factory: RTCPeerConnectionFactory
	private(set) var opponent: SVUser
	private(set) var ICECandidates: [RTCIceCandidate] = []
	private(set) var ICEServers: [RTCIceServer]
	private(set) var state = PeerConnectionState.Initial
	
	private var observers: MulticastDelegate<PeerConnectionObserver>?
	
	init(opponent: SVUser, sessionID: String, ICEServers: [RTCIceServer], factory: RTCPeerConnectionFactory, mediaStreamConstraints: RTCMediaConstraints, peerConnectionConstraints: RTCMediaConstraints, offerAnswerConstraints: RTCMediaConstraints) {
		self.opponent = opponent
		self.sessionID = sessionID
		self.ICEServers = ICEServers
		self.mediaStreamConstraints = mediaStreamConstraints
		self.peerConnectionConstraints = peerConnectionConstraints
		self.offerAnswerConstraints = offerAnswerConstraints
		self.factory = factory
	}
	
	func addObserver(observer: PeerConnectionObserver) {
		observers += observer
	}
	
	func startCall() {
		let configuration = RTCConfiguration()
		configuration.iceServers = ICEServers
		peerConnection = factory.peerConnectionWithConfiguration(configuration, constraints: peerConnectionConstraints, delegate: self)
		peerConnection?.delegate = self
		
		// Create AV media stream and add it to the peer connection.
		peerConnection?.addStream(createLocalMediaStream())
		
		// Send offer.
		peerConnection?.offerForConstraints(offerAnswerConstraints, completionHandler: { [weak self] (sdp, error) in
			guard let strongSelf = self else { return }
			
			if let error = error {
				NSLog("%@", "Error failed to set local offer \(error)")
				strongSelf.observers => { $0.peerConnection(strongSelf, didCreateSessionWithError: error) }
				return
			}
			
			guard let sessionDescription = sdp else {
				NSLog("%@", "Error SDP Offer is nil")
				return
			}
			
			let sdpPreferringH264 = WebRTCHelpers.descriptionForDescription(sessionDescription, preferredVideoCodec: "H264")
			strongSelf.peerConnection?.setLocalDescription(sdpPreferringH264, completionHandler: { (error) in
				if let error = error {
					NSLog("%@", "Error setLocalDescription \(error)")
					strongSelf.observers => { $0.peerConnection(strongSelf, didCreateSessionWithError: error) }
					return
				}
				strongSelf.observers => { $0.peerConnection(strongSelf, didSetLocalSessionOfferDescription: strongSelf.peerConnection!.localDescription!) }
			})
			})
	}
	
	func acceptCall() {
		let configuration = RTCConfiguration()
		configuration.iceServers = ICEServers
		peerConnection = factory.peerConnectionWithConfiguration(configuration, constraints: peerConnectionConstraints, delegate: self)
		peerConnection?.delegate = self
		
		// Create AV media stream and add it to the peer connection.
		peerConnection?.addStream(createLocalMediaStream())
	}
	
	func close() {
		state = .Closed
		peerConnection?.delegate = nil
		if let localStreams = peerConnection?.localStreams {
			for stream in localStreams {
				peerConnection?.removeStream(stream)
			}
		}
		peerConnection?.close()
		peerConnection = nil
		ICECandidates.removeAll()
	}
	
	// Processing incoming events from opponent
	func applyRemoteSDP(sdp: RTCSessionDescription) {
		NSLog("Received remote SDP for opponent \(opponent)")
		peerConnection?.setRemoteDescription(sdp, completionHandler: { [weak self] (error) in
			guard let strongSelf = self else { return }
			if let error = error {
				NSLog("%@", "Error failed to set remote offer \(error)")
				strongSelf.observers => { $0.peerConnection(strongSelf, didCreateSessionWithError: error) }
				return
			}
			
			guard sdp.type == .Offer else { return }
			// We cannot create an answer for an answer
			
			strongSelf.peerConnection!.answerForConstraints(strongSelf.offerAnswerConstraints, completionHandler: { (sdpAnswer, error) in
				if let error = error {
					NSLog("%@", "Error failed to create offer \(error)")
					strongSelf.observers => { $0.peerConnection(strongSelf, didCreateSessionWithError: error) }
					return
				}
				guard let sessionDescription = sdpAnswer else {
					NSLog("%@", "Error SDP Answer is nil")
					return
				}
				strongSelf.peerConnection?.setLocalDescription(sessionDescription, completionHandler: { (error) in
					if let error = error {
						NSLog("%@", "Error failed to set local description \(error)")
						strongSelf.observers => { $0.peerConnection(strongSelf, didCreateSessionWithError: error) }
						return
					}
					
					if strongSelf.state != .Closed {
						// RTCSignalingStable means that we applied remote offer SDP, created answer, applied local SDP
						// and now local SPD has been set
						strongSelf.observers => { $0.peerConnection(strongSelf, didSetLocalSessionAnswerDescription: strongSelf.peerConnection!.localDescription!) }
					}
				})
			})
			})
	}
	
	func applyICECandidates(ICECandidates: [RTCIceCandidate]) {
		for candidate in ICECandidates {
			peerConnection?.addIceCandidate(candidate)
		}
	}
}

extension PeerConnection: RTCPeerConnectionDelegate {
	func peerConnection(peerConnection: RTCPeerConnection, didChangeSignalingState stateChanged: RTCSignalingState) {
		let signalingState = SVRTCSignalingState(stateChanged)
		NSLog("Signaling state changed: \(signalingState)");
	}
	
	func peerConnection(peerConnection: RTCPeerConnection, didAddStream stream: RTCMediaStream) {
		NSLog("Received \(stream.videoTracks.count) video tracks and \(stream.audioTracks.count) audio tracks");
		if let videoTrack = stream.videoTracks.first {
			observers => {$0.peerConnection(self, didReceiveRemoteVideoTrack: videoTrack)}
		}
	}
	
	func peerConnection(peerConnection: RTCPeerConnection, didRemoveStream stream: RTCMediaStream) {
		NSLog("Stream removed")
	}
	
	func peerConnection(peerConnection: RTCPeerConnection, didChangeIceConnectionState newState: RTCIceConnectionState) {
		if newState == .Failed {
			NSLog("ICE connection failed")
		}
	}
	func peerConnection(peerConnection: RTCPeerConnection, didChangeIceGatheringState newState: RTCIceGatheringState) {
		
	}
	
	func peerConnection(peerConnection: RTCPeerConnection, didGenerateIceCandidate candidate: RTCIceCandidate) {
		// TODO: make a queue and send when local ICE candidates have been collected
		ICECandidates += candidate
		observers => { $0.peerConnection(self, didSetLocalICECandidates: candidate) }
		ICECandidates.removeAll()
	}
	
	func peerConnectionShouldNegotiate(peerConnection: RTCPeerConnection) {
		
	}
	
	func peerConnection(peerConnection: RTCPeerConnection, didOpenDataChannel dataChannel: RTCDataChannel) {
		
	}
	
	func peerConnection(peerConnection: RTCPeerConnection, didRemoveIceCandidates candidates: [RTCIceCandidate]) {
		
	}
}

// MARK: - Creating local media stream
private extension PeerConnection {
	func createLocalMediaStream() -> RTCMediaStream {
		
		let localStream = factory.mediaStreamWithStreamId("ARDAMS")
		if let localVideoTrack = createLocalVideoTrack() {
			localStream.addVideoTrack(localVideoTrack)
			observers => {$0.peerConnection(self, didReceiveLocalVideoTrack: localVideoTrack)}
		} else if NSClassFromString("XCTest") != nil {
			// For test purposes let's just create an empty video track
			let videoSource = factory.avFoundationVideoSourceWithConstraints(mediaStreamConstraints)
			let emptyVideoTrack = factory.videoTrackWithSource(videoSource, trackId: "trackID")
			
			observers => {$0.peerConnection(self, didReceiveLocalVideoTrack: emptyVideoTrack)}
		}
		
		let localAudioTrack = factory.audioTrackWithTrackId("ARDAMSa0")
		localStream.addAudioTrack(localAudioTrack)
		observers => {$0.peerConnection(self, didReceiveLocalAudioTrack: localAudioTrack)}
		
		return localStream
	}
	
	func createLocalVideoTrack() -> RTCVideoTrack? {
		#if (arch(i386) || arch(x86_64)) && os(iOS)
			return nil // desktop
		#else
			let source = factory.avFoundationVideoSourceWithConstraints(mediaStreamConstraints)
			let localVideoTrack = factory.videoTrackWithSource(source, trackId: "ARDAMSv0")
			return localVideoTrack
		#endif
	}
}
