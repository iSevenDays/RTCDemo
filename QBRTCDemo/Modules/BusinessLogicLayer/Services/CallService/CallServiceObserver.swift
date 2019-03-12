//
//  CallServiceObserver.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 09.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

protocol CallServiceObserver: class {
	
	func callService(_ callService: CallServiceProtocol, didReceiveCallRequestFromOpponent opponent: SVUser)
	func callService(_ callService: CallServiceProtocol, didReceiveAnswerFromOpponent opponent: SVUser)
	func callService(_ callService: CallServiceProtocol, didReceiveHangupFromOpponent opponent: SVUser)
	func callService(_ callService: CallServiceProtocol, didReceiveRejectFromOpponent opponent: SVUser)
	func callService(_ callService: CallServiceProtocol, didAnswerTimeoutForOpponent opponent: SVUser)
	func callService(_ callService: CallServiceProtocol, didChangeConnectionState state: RTCIceConnectionState)
	func callService(_ callService: CallServiceProtocol, didChangeState state: CallServiceState)
	func callService(_ callService: CallServiceProtocol, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack)
	func callService(_ callService: CallServiceProtocol, didReceiveLocalAudioTrack localAudioTrack: RTCAudioTrack)
	func callService(_ callService: CallServiceProtocol, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack)
	func callService(_ callService: CallServiceProtocol, didError error: Error)
	func callService(_ callService: CallServiceProtocol, didReceiveUser user: SVUser, forChatRoomName chatRoomName: String)
	
	func callService(_ callService: CallServiceProtocol, didStartDialingOpponent opponent: SVUser)
	
	// Note: the method is not called when current user hangups a call
	func callService(_ callService: CallServiceProtocol, didStopDialingOpponent opponent: SVUser)
	
	// Sending local SDP
	func callService(_ callService: CallServiceProtocol, didSendLocalSessionDescriptionMessage: SignalingMessage, toOpponent opponent: SVUser)
	func callService(_ callService: CallServiceProtocol, didErrorSendingLocalSessionDescriptionMessage: SignalingMessage, toOpponent opponent: SVUser, error: Error)
	
	// Sending local ICE candidates
	func callService(_ callService: CallServiceProtocol, didSendLocalICECandidates: [RTCIceCandidate], toOpponent opponent: SVUser)
	func callService(_ callService: CallServiceProtocol, didErrorSendingLocalICECandidates: [RTCIceCandidate], toOpponent opponent: SVUser, error: Error)
	
	// Send reject to a user
	// Also reject is send when CallService has active call by the moment
	// New offer for a call is received
	func callService(_ callService: CallServiceProtocol, didSendRejectToOpponent opponent: SVUser)
	
	func callService(_ callService: CallServiceProtocol, didSendHangupToOpponent opponent: SVUser)
	
	func callService(_ callService: CallServiceProtocol, didSendUserEnteredChatRoomName chatRoomName: String, toUser: SVUser)
}

extension CallServiceObserver {
	func callService(_ callService: CallServiceProtocol, didReceiveCallRequestFromOpponent opponent: SVUser){}
	func callService(_ callService: CallServiceProtocol, didReceiveAnswerFromOpponent opponent: SVUser){}
	func callService(_ callService: CallServiceProtocol, didReceiveHangupFromOpponent opponent: SVUser){}
	func callService(_ callService: CallServiceProtocol, didReceiveRejectFromOpponent opponent: SVUser){}
	func callService(_ callService: CallServiceProtocol, didAnswerTimeoutForOpponent opponent: SVUser){}
	func callService(_ callService: CallServiceProtocol, didChangeConnectionState state: RTCIceConnectionState){}
	func callService(_ callService: CallServiceProtocol, didChangeState state: CallServiceState){}
	func callService(_ callService: CallServiceProtocol, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack){}
	func callService(_ callService: CallServiceProtocol, didReceiveLocalAudioTrack localAudioTrack: RTCAudioTrack){}
	func callService(_ callService: CallServiceProtocol, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack){}
	func callService(_ callService: CallServiceProtocol, didError error: Error){}
	func callService(_ callService: CallServiceProtocol, didReceiveUser user: SVUser, forChatRoomName chatRoomName: String){}
	
	func callService(_ callService: CallServiceProtocol, didStartDialingOpponent opponent: SVUser){}
	func callService(_ callService: CallServiceProtocol, didStopDialingOpponent opponent: SVUser){}
	
	// Sending local SDP
	func callService(_ callService: CallServiceProtocol, didSendLocalSessionDescriptionMessage: SignalingMessage, toOpponent opponent: SVUser) {}
	func callService(_ callService: CallServiceProtocol, didErrorSendingLocalSessionDescriptionMessage: SignalingMessage, toOpponent opponent: SVUser, error: Error) {}
	
	// Sending local ICE candidates
	func callService(_ callService: CallServiceProtocol, didSendLocalICECandidates: [RTCIceCandidate], toOpponent opponent: SVUser) {}
	func callService(_ callService: CallServiceProtocol, didErrorSendingLocalICECandidates: [RTCIceCandidate], toOpponent opponent: SVUser, error: Error) {}
	
	func callService(_ callService: CallServiceProtocol, didSendRejectToOpponent opponent: SVUser) {}
	func callService(_ callService: CallServiceProtocol, didSendHangupToOpponent opponent: SVUser) {}
	func callService(_ callService: CallServiceProtocol, didSendUserEnteredChatRoomName chatRoomName: String, toUser: SVUser) {}
}
