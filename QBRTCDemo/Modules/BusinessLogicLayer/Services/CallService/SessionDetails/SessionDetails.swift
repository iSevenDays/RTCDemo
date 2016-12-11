//
//  SessionDetails.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 08.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

@objc enum SessionDetailsState: Int {
	case Undefined
	case OfferSent
	case OfferReceived
	case AnswerSent
	case AnswerReceived
	case Established
	case Rejected
	case Closed
}

class SessionDetails: NSObject {
	
	/// Unique session identifier
	var sessionID: String
	var initiatorID: UInt
	var sessionState = SessionDetailsState.Undefined
	
	// all users in current session including initiator
	var membersIDs: [UInt]
	
	// Generate new SessionDetails
	init(initiatorID: UInt, membersIDs: [UInt]) {
		sessionID = NSUUID().UUIDString
		self.initiatorID = initiatorID
		self.membersIDs = membersIDs
	}
	
	// Init existing SessionDetails
	init(initiatorID: UInt, membersIDs: [UInt], sessionID: String) {
		self.initiatorID = initiatorID
		self.membersIDs = membersIDs
		self.sessionID = sessionID
	}
	
	override func isEqual(object: AnyObject?) -> Bool {
		guard let anotherSession = object as? SessionDetails else {
			return false
		}
		return sessionID == anotherSession.sessionID && membersIDs == anotherSession.membersIDs && anotherSession.initiatorID == anotherSession.initiatorID
	}
}
