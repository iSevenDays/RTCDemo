//
//  PeerConnection.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 09.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

protocol PeerConnectionObserver: class {
	func peerConnection(peerConnection: PeerConnection, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack)
	func peerConnection(peerConnection: PeerConnection, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack)
	func peerConnection(peerConnection: PeerConnection, didCreateSessionWithError error: NSError)
}

enum PeerConnectionState {
	case Initial
	case Closed
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
}

extension PeerConnection: RTCPeerConnectionDelegate {
	func peerConnection(peerConnection: RTCPeerConnection!, signalingStateChanged stateChanged: RTCSignalingState) {
		NSLog("Signaling state changed: \(stateChanged)");
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
			NSLog("ICE connecttion failed")
		}
	}
	
	func peerConnection(peerConnection: RTCPeerConnection!, iceGatheringChanged newState: RTCICEGatheringState) {
		
	}
	
	
	func peerConnectionOnRenegotiationNeeded(peerConnection: RTCPeerConnection!) {
		
	}
	
	func peerConnection(peerConnection: RTCPeerConnection!, didOpenDataChannel dataChannel: RTCDataChannel!) {
		
	}
	
	func peerConnection(peerConnection: RTCPeerConnection!, gotICECandidate candidate: RTCICECandidate!) {
		ICECandidates += candidate
	}
}

extension PeerConnection: RTCSessionDescriptionDelegate {
	func peerConnection(peerConnection: RTCPeerConnection!, didCreateSessionDescription sdp: RTCSessionDescription!, error: NSError!) {
		let sdpPreferringH264 = WebRTCHelpers.descriptionForDescription(sdp, preferredVideoCodec: "H264")
		
		peerConnection?.setLocalDescriptionWithDelegate(self, sessionDescription: sdpPreferringH264)
	}
	
	func peerConnection(peerConnection: RTCPeerConnection!, didSetSessionDescriptionWithError error: NSError!) {
		guard error == nil else {
			observers => { $0.peerConnection(self, didCreateSessionWithError: error) }
			return
		}
		
		if peerConnection.signalingState == RTCSignalingHaveLocalOffer {
			// send signaling offer
		} else if peerConnection.signalingState == RTCSignalingHaveRemoteOffer {
			peerConnection.createAnswerWithDelegate(self, constraints: offerAnswerConstraints)
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
