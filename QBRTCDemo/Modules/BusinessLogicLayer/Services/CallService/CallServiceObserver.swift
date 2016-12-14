//
//  CallServiceObserver.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 09.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

protocol CallServiceObserver: class {
	
	func callService(callService: CallServiceProtocol, didReceiveCallRequestFromOpponent opponent: SVUser)
	func callService(callService: CallServiceProtocol, didReceiveAnswerFromOpponent opponent: SVUser)
	func callService(callService: CallServiceProtocol, didReceiveHangupFromOpponent opponent: SVUser)
	func callService(callService: CallServiceProtocol, didReceiveRejectFromOpponent opponent: SVUser)
	func callService(callService: CallServiceProtocol, didAnswerTimeoutForOpponent opponent: SVUser)
	func callService(callService: CallServiceProtocol, didChangeConnectionState state: RTCICEConnectionState)
	func callService(callService: CallServiceProtocol, didChangeState state: CallServiceState)
	func callService(callService: CallServiceProtocol, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack)
	func callService(callService: CallServiceProtocol, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack)
	func callService(callService: CallServiceProtocol, didError error: NSError)
	
	func callService(callService: CallServiceProtocol, didStartDialingOpponent opponent: SVUser)
	
	// Note: the method is not called when current user hangups a call
	func callService(callService: CallServiceProtocol, didStopDialingOpponent opponent: SVUser)
	
	// Sending local SDP
	func callService(callService: CallServiceProtocol, didSendLocalSessionDescriptionMessage: SignalingMessage, toOpponent opponent: SVUser)
	func callService(callService: CallServiceProtocol, didErrorSendingLocalSessionDescriptionMessage: SignalingMessage, toOpponent opponent: SVUser, error: NSError)
	
	// Sending local ICE candidates
	func callService(callService: CallServiceProtocol, didSendLocalICECandidates: [RTCICECandidate], toOpponent opponent: SVUser)
	func callService(callService: CallServiceProtocol, didErrorSendingLocalICECandidates: [RTCICECandidate], toOpponent opponent: SVUser, error: NSError)
}

extension CallServiceObserver {
	func callService(callService: CallServiceProtocol, didReceiveCallRequestFromOpponent opponent: SVUser){}
	func callService(callService: CallServiceProtocol, didReceiveAnswerFromOpponent opponent: SVUser){}
	func callService(callService: CallServiceProtocol, didReceiveHangupFromOpponent opponent: SVUser){}
	func callService(callService: CallServiceProtocol, didReceiveRejectFromOpponent opponent: SVUser){}
	func callService(callService: CallServiceProtocol, didAnswerTimeoutForOpponent opponent: SVUser){}
	func callService(callService: CallServiceProtocol, didChangeConnectionState state: RTCICEConnectionState){}
	func callService(callService: CallServiceProtocol, didChangeState state: CallServiceState){}
	func callService(callService: CallServiceProtocol, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack){}
	func callService(callService: CallServiceProtocol, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack){}
	func callService(callService: CallServiceProtocol, didError error: NSError){}
	
	func callService(callService: CallServiceProtocol, didStartDialingOpponent opponent: SVUser){}
	func callService(callService: CallServiceProtocol, didStopDialingOpponent opponent: SVUser){}
	
	// Sending local SDP
	func callService(callService: CallServiceProtocol, didSendLocalSessionDescriptionMessage: SignalingMessage, toOpponent opponent: SVUser) {}
	func callService(callService: CallServiceProtocol, didErrorSendingLocalSessionDescriptionMessage: SignalingMessage, toOpponent opponent: SVUser, error: NSError) {}
	
	// Sending local ICE candidates
	func callService(callService: CallServiceProtocol, didSendLocalICECandidates: [RTCICECandidate], toOpponent opponent: SVUser) {}
	func callService(callService: CallServiceProtocol, didErrorSendingLocalICECandidates: [RTCICECandidate], toOpponent opponent: SVUser, error: NSError) {}
}
