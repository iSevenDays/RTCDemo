//
//  SessionDetails.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 08.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

enum SessionDetailsState: String, Codable {
	case undefined
	case offerSent
	case offerReceived
	case answerSent
	case answerReceived
	case established
	case rejected
	case closed
}

class SessionDetails: Codable {
	
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

	// Codable
	enum CodingKeys: String, CodingKey {
		case sessionID
		case initiatorID
		case sessionState
		case membersIDs
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(sessionID, forKey: .sessionID)
		try container.encode(initiatorID, forKey: .initiatorID)
		try container.encode(sessionState, forKey: .sessionState)
		try container.encode(membersIDs, forKey: .membersIDs)
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		sessionID = try container.decode(String.self, forKey: .sessionID)
		initiatorID = try container.decode(UInt.self, forKey: .initiatorID)
		sessionState = try container.decode(SessionDetailsState.self, forKey: .sessionState)
		membersIDs = try container.decode([UInt].self, forKey: .membersIDs)
	}
}


extension SessionDetailsState: Equatable {
}

func ==(lhs: SessionDetails, rhs: SessionDetails) -> Bool {
	
	return lhs.sessionID == rhs.sessionID && lhs.membersIDs == rhs.membersIDs && lhs.initiatorID == rhs.initiatorID
}
