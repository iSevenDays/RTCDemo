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
	
	init(initiator: SVUser, membersIDs: [UInt]) {
		sessionID = NSUUID().UUIDString
		self.initiatorID = initiator.ID!.unsignedIntegerValue
		self.membersIDs = membersIDs
	}
	
	init(signalingMessage: SVSignalingMessage) {
		sessionID = signalingMessage.params[SVSignalingParams.sessionID.takeUnretainedValue() as String]!
		initiatorID = UInt(signalingMessage.params[SVSignalingParams.initiatorID.takeUnretainedValue() as String]!)!
		let membersSeparatedByComma = signalingMessage.params[SVSignalingParams.membersIDs.takeUnretainedValue() as String]!
		membersIDs = membersSeparatedByComma.componentsSeparatedByString(",").flatMap({UInt($0)})
		super.init()
	}
	
}
