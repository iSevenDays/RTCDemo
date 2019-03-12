//
//  SessionDetails.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 08.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

enum SessionDetailsState {
	case undefined
	case offerSent
	case offerReceived
	case answerSent
	case answerReceived
	case established
	case rejected
	case closed
}

class SessionDetails {
	
	/// Unique session identifier
	var sessionID: String
	var initiatorID: UInt
	var sessionState = SessionDetailsState.undefined
	
	// all users in current session including initiator
	var membersIDs: [UInt]
	
	// Generate new SessionDetails
	init(initiatorID: UInt, membersIDs: [UInt]) {
		sessionID = UUID().uuidString
		self.initiatorID = initiatorID
		self.membersIDs = membersIDs
	}
	
	// Init existing SessionDetails
	init(initiatorID: UInt, membersIDs: [UInt], sessionID: String) {
		self.initiatorID = initiatorID
		self.membersIDs = membersIDs
		self.sessionID = sessionID
	}
}

extension SessionDetailsState: Equatable {
}

func ==(lhs: SessionDetails, rhs: SessionDetails) -> Bool {
	
	return lhs.sessionID == rhs.sessionID && lhs.membersIDs == rhs.membersIDs && lhs.initiatorID == rhs.initiatorID
}
