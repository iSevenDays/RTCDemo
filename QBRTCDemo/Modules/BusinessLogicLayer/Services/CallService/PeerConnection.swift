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
	func peerConnection(peerConnection: PeerConnection, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack)
	func peerConnection(peerConnection: PeerConnection, didCreateSessionWithError error: NSError)
	func peerConnection(peerConnection: PeerConnection, didSetLocalICECandidates localICECandidates: RTCICECandidate)
	
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
	case RTCSignalingStable: return "RTCSignalingStable"
	case RTCSignalingHaveLocalOffer: return "RTCSignalingHaveLocalOffer"
	case RTCSignalingHaveLocalPrAnswer: return "RTCSignalingHaveLocalPrAnswer"
	case RTCSignalingHaveRemoteOffer: return "RTCSignalingHaveRemoteOffer"
	case RTCSignalingHaveRemotePrAnswer: return "RTCSignalingHaveRemotePrAnswer"
	case RTCSignalingClosed: return "RTCSignalingClosed"
	default: return "Undefined"
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
	private(set) var ICECandidates: [RTCICECandidate] = []
	private(set) var ICEServers: [RTCICEServer]
	private(set) var state = PeerConnectionState.Initial
	
	private var observers: MulticastDelegate<PeerConnectionObserver>?
	
	init(opponent: SVUser, sessionID: String, ICEServers: [RTCICEServer], factory: RTCPeerConnectionFactory, mediaStreamConstraints: RTCMediaConstraints, peerConnectionConstraints: RTCMediaConstraints, offerAnswerConstraints: RTCMediaConstraints) {
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
		peerConnection?.createOfferWithDelegate(self, constraints: offerAnswerConstraints)
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
		if let localStreams = peerConnection?.localStreams as? [RTCMediaStream] {
			for stream in localStreams {
				peerConnection?.removeStream(stream)
			}
		}
		peerConnection?.close()
		peerConnection = nil
		ICECandidates.removeAll()
	}
	
	// Processign incoming events from opponent
	func applyRemoteSDP(sdp: RTCSessionDescription) {
		NSLog("Received remote SDP for opponent \(opponent)")
		peerConnection?.setRemoteDescriptionWithDelegate(self, sessionDescription: sdp)
	}
	
	func applyICECandidates(ICECandidates: [RTCICECandidate]) {
		for candidate in ICECandidates {
			peerConnection?.addICECandidate(candidate)
		}
	}
	var latestSDP: String = ""
}

extension PeerConnection: RTCPeerConnectionDelegate {
	func peerConnection(peerConnection: RTCPeerConnection!, signalingStateChanged stateChanged: RTCSignalingState) {
		let signalingState = SVRTCSignalingState(stateChanged)
		NSLog("Signaling state changed: \(signalingState)");
	}
	
	func peerConnection(peerConnection: RTCPeerConnection!, addedStream stream: RTCMediaStream!) {
		NSLog("Received \(stream.videoTracks.count) video tracks and \(stream.audioTracks.count) audio tracks");
		if let videoTrack = stream.videoTracks.first as? RTCVideoTrack {
			observers => {$0.peerConnection(self, didReceiveRemoteVideoTrack: videoTrack)}
		}
	}
	
	func peerConnection(peerConnection: RTCPeerConnection!, removedStream stream: RTCMediaStream!) {
		NSLog("Stream removed")
	}
	
	func peerConnection(peerConnection: RTCPeerConnection!, iceConnectionChanged newState: RTCICEConnectionState) {
		if newState == RTCICEConnectionFailed {
			NSLog("ICE connection failed")
		}
	}
	
	func peerConnection(peerConnection: RTCPeerConnection!, iceGatheringChanged newState: RTCICEGatheringState) {
		
	}
	
	
	func peerConnectionOnRenegotiationNeeded(peerConnection: RTCPeerConnection!) {
		
	}
	
	func peerConnection(peerConnection: RTCPeerConnection!, didOpenDataChannel dataChannel: RTCDataChannel!) {
		
	}
	
	
	func peerConnection(peerConnection: RTCPeerConnection!, gotICECandidate candidate: RTCICECandidate!) {
		// TODO: make a queue and send when local ICE candidates have been collected
		ICECandidates += candidate
		observers => { $0.peerConnection(self, didSetLocalICECandidates: candidate) }
		ICECandidates.removeAll()
		
		latestSDP = candidate.sdp
	}
}

extension PeerConnection: RTCSessionDescriptionDelegate {
	func peerConnection(peerConnection: RTCPeerConnection!, didCreateSessionDescription sdp: RTCSessionDescription!, error: NSError!) {
		let sdpPreferringH264 = WebRTCHelpers.descriptionForDescription(sdp, preferredVideoCodec: "H264")
		
		peerConnection?.setLocalDescriptionWithDelegate(self, sessionDescription: sdpPreferringH264)
	}
	
	func peerConnection(peerConnection: RTCPeerConnection!, didSetSessionDescriptionWithError error: NSError!) {
		NSLog("Signaling state: \(SVRTCSignalingState(peerConnection.signalingState))");
		
		guard error == nil else {
			NSLog("%@", "Error: didSetSessionDescriptionWithError \(error)")
			observers => { $0.peerConnection(self, didCreateSessionWithError: error) }
			return
		}
		
		if peerConnection.signalingState == RTCSignalingHaveLocalOffer {
			observers => { $0.peerConnection(self, didSetLocalSessionOfferDescription: peerConnection.localDescription) }
		} else if peerConnection.signalingState == RTCSignalingHaveRemoteOffer {
			peerConnection.createAnswerWithDelegate(self, constraints: offerAnswerConstraints)
		} else if peerConnection.signalingState == RTCSignalingStable {
			// RTCSignalingStable means that we applied remote offer SDP, created answer, applied local SDP
			// and now local SPD has been set
			observers => { $0.peerConnection(self, didSetLocalSessionAnswerDescription: peerConnection.localDescription) }
		}
	}
}

// MARK: - Creating local media stream
private extension PeerConnection {
	func createLocalMediaStream() -> RTCMediaStream {
		let localStream = factory.mediaStreamWithLabel("ARDAMS")
		if let localVideoTrack = createLocalVideoTrack() {
			localStream.addVideoTrack(localVideoTrack)
			observers => {$0.peerConnection(self, didReceiveLocalVideoTrack: localVideoTrack)}
		} else if NSClassFromString("XCTest") != nil {
			// For test purposes let's just create an empty video track
			let videoSourceClass: AnyClass = RTCVideoSource.self
			let videoSourceInitializable = videoSourceClass as! NSObject.Type
			let videoSource = videoSourceInitializable.init() as! RTCVideoSource
			
			let emptyVideoTrack = RTCVideoTrack(factory: factory, source: videoSource, trackId: "trackID")
			
			observers => {$0.peerConnection(self, didReceiveLocalVideoTrack: emptyVideoTrack)}
		}
		localStream.addAudioTrack(factory.audioTrackWithID("ARDAMSa0"))
		return localStream
	}
	
	func createLocalVideoTrack() -> RTCVideoTrack? {
		#if (arch(i386) || arch(x86_64)) && os(iOS)
			return nil // desktop
		#else
			let source = RTCAVFoundationVideoSource(factory: factory, constraints: mediaStreamConstraints)
			let localVideoTrack = RTCVideoTrack(factory: factory, source: source, trackId: "ARDAMSv0")
			return localVideoTrack
		#endif
	}
}
