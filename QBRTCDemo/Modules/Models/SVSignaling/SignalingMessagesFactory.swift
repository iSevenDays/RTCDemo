//
//  SignalingMessagesFactory.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation
//
enum SignalingMessagesFactoryError: ErrorType {
	case incorrectSignalingMessage(message: QBChatMessage)
	case failedToDecompressMessage(message: QBChatMessage)
	case undefinedSignalingMessageType
	case incorrectParamsType
	case missingSDP
	case missingSender
	case missingInitiatorID
	case missingSessionID
	case missingMembersIDs
	case errorCompressingCustomParams
}

enum SignalingMessageType: String {
	case candidates = "candidates"
	case offer = "offer"
	case answer = "answer"
	case hangup = "hangup"
	case reject = "reject"
	case userEnteredChatRoom = "userForChatRoom"
}

enum SignalingParams: String {
	case type = "type"
    case sdp = "sdp"
	
	case candidates = "candidates"
	
	case mid = "mid"
	case index = "index"
	
	// Session Details params
	case sessionID = "sessionID"
	case membersIDs = "membersIDs"
	case initiatorID = "initiatorID"
	
	// SVUser sender params
	case senderLogin = "login"
	case senderFullName = "fullName"
	
	// Chat room name for sender
	case roomName = "roomName"
	
	// Compressed data - contains all information above 
	case compressedData = "compressedData"
}

class SignalingMessagesFactory {
	
	func qbMessageFromSignalingMessage(message: SignalingMessage, sender: SVUser, sessionDetails: SessionDetails?) throws -> QBChatMessage {
		var params: [String: AnyObject] = [:]
		
		// SVUser sender populating
		params[SignalingParams.senderLogin.rawValue] = sender.login
		params[SignalingParams.senderFullName.rawValue] = sender.fullName
		
		// SessionDetails populating
		if let sessionDetails = sessionDetails {
			params[SignalingParams.sessionID.rawValue] = sessionDetails.sessionID
			params[SignalingParams.membersIDs.rawValue] = sessionDetails.membersIDs.flatMap({String($0)}).joinWithSeparator(",")
			params[SignalingParams.initiatorID.rawValue] = String(sessionDetails.initiatorID)
		}
		switch message {
		case let .answer(sdp: sessionDescription):
			params[SignalingParams.type.rawValue] = SignalingMessageType.answer.rawValue
			params[SignalingParams.sdp.rawValue] = sessionDescription.sdp
			break
		case let .offer(sdp: sessionDescription):
			params[SignalingParams.type.rawValue] = SignalingMessageType.offer.rawValue
			params[SignalingParams.sdp.rawValue] = sessionDescription.sdp
			break
		case let .candidates(candidates: candidates):
			params[SignalingParams.type.rawValue] = SignalingMessageType.candidates.rawValue
			var candidatesDict: [[String: String]] = []
			for candidate in candidates {
				candidatesDict.append([
					SignalingParams.index.rawValue: String(candidate.sdpMLineIndex),
					SignalingParams.mid.rawValue: candidate.sdpMid!,
					SignalingParams.sdp.rawValue: candidate.sdp])
				
			}
			params[SignalingParams.candidates.rawValue] = candidatesDict
			
			break
		case .hangup:
			params[SignalingParams.type.rawValue] = SignalingMessageType.hangup.rawValue
			break
		case .reject:
			params[SignalingParams.type.rawValue] = SignalingMessageType.reject.rawValue
			break
		case let .user(enteredChatRoomName: roomName):
			params[SignalingParams.type.rawValue] = SignalingMessageType.userEnteredChatRoom.rawValue
			params[SignalingParams.roomName.rawValue] = roomName
			break
		}
		
		// Compression
		guard let compressedParams = compressedCustomParams(params) else {
			throw SignalingMessagesFactoryError.errorCompressingCustomParams
		}
		
		let qbMessage = QBChatMessage()
		qbMessage.customParameters[SignalingParams.compressedData.rawValue] = compressedParams
		return qbMessage
	}
	
	/**
	Parses SignalingMessage from QBChatMessage
	
	- parameter message: QBChatMessage instance
	
	- throws: SignalingMessagesFactoryError type
	
	- returns: return message, sender, sessionDetails(nil for chat room SignalingMessage)
	*/
	func signalingMessageFromQBMessage(message: QBChatMessage) throws -> (message: SignalingMessage, sender: SVUser, sessionDetails: SessionDetails?) {
		guard let base64Representation = message.customParameters[SignalingParams.compressedData.rawValue] as? String else {
			throw SignalingMessagesFactoryError.incorrectSignalingMessage(message: message)
		}
		guard let decodedBase64Data = NSData(base64EncodedString: base64Representation, options: NSDataBase64DecodingOptions(rawValue: 0)) else {
			throw SignalingMessagesFactoryError.incorrectSignalingMessage(message: message)
		}
		guard let ungzippedData = decodedBase64Data.gunzippedData() else {
			throw SignalingMessagesFactoryError.failedToDecompressMessage(message: message)
		}
		guard let params = try NSJSONSerialization.JSONObjectWithData(ungzippedData, options: NSJSONReadingOptions.AllowFragments) as? [String: AnyObject] else {
			throw SignalingMessagesFactoryError.incorrectParamsType
		}
		guard let signalingMessageTypeString = params[SignalingParams.type.rawValue] as? String else {
			throw SignalingMessagesFactoryError.undefinedSignalingMessageType
		}
		guard let signalingMessageType = SignalingMessageType(rawValue: signalingMessageTypeString) else {
			throw SignalingMessagesFactoryError.undefinedSignalingMessageType
		}
		
		// SVUser sender populating
		guard let userLogin = params[SignalingParams.senderLogin.rawValue] as? String else {
			throw SignalingMessagesFactoryError.missingSender
		}
		guard let userFullName = params[SignalingParams.senderFullName.rawValue] as? String else {
			throw SignalingMessagesFactoryError.missingSender
		}
		let sender = SVUser(ID: message.senderID, login: userLogin, fullName: userFullName, password: nil, tags: nil)
		
		// SessionDetails populating
		var sessionDetails: SessionDetails?
		
		switch signalingMessageType {
		case .answer, .candidates, .hangup, .offer, .reject:
			guard let initiatorID = params[SignalingParams.initiatorID.rawValue] as? String else {
				throw SignalingMessagesFactoryError.missingInitiatorID
			}
			guard let sessionID = params[SignalingParams.sessionID.rawValue] as? String else {
				throw SignalingMessagesFactoryError.missingSessionID
			}
			guard let membersIDs = (params[SignalingParams.membersIDs.rawValue] as? String)?.componentsSeparatedByString(",").flatMap({UInt.init($0)}) else {
				throw SignalingMessagesFactoryError.missingMembersIDs
			}
			sessionDetails = SessionDetails(initiatorID: UInt(initiatorID)!, membersIDs: membersIDs, sessionID: sessionID)
		case .userEnteredChatRoom: break
		}
		
		switch signalingMessageType {
		case .answer, .offer:
			guard let sourceSDP = params[SignalingParams.sdp.rawValue]?.stringByReplacingOccurrencesOfString("&#13;", withString: "\r") else {
				throw SignalingMessagesFactoryError.missingSDP
			}
			
			if signalingMessageType == .offer {
				let sdp = RTCSessionDescription(type: .Offer, sdp: sourceSDP)
				return (message: SignalingMessage.offer(sdp: sdp), sender: sender, sessionDetails: sessionDetails)
			} else if signalingMessageType == .answer {
				let sdp = RTCSessionDescription(type: .Answer, sdp: sourceSDP)
				return (message: SignalingMessage.answer(sdp: sdp), sender: sender, sessionDetails: sessionDetails)
			}
		case .candidates:
			guard let candidates = params[SignalingParams.candidates.rawValue] as? [[String: String]] else {
				throw SignalingMessagesFactoryError.undefinedSignalingMessageType
			}
			var iceCandidates: [RTCIceCandidate] = []
			for candidate in candidates {
				guard let mid = candidate[SignalingParams.mid.rawValue] else {
					continue
				}
				guard let indexStr = candidate[SignalingParams.index.rawValue] else {
					continue
				}
				guard let index = Int32(indexStr) else {
					continue
				}
				guard let candidateSDP = candidate[SignalingParams.sdp.rawValue]?.stringByReplacingOccurrencesOfString("&#13;", withString: "\r") else {
					continue
				}
				let iceCandidate = RTCIceCandidate(sdp: candidateSDP, sdpMLineIndex: index, sdpMid: mid)
				iceCandidates += iceCandidate
			}
			return (message: SignalingMessage.candidates(candidates: iceCandidates), sender: sender, sessionDetails: sessionDetails)
			
		case .hangup: return (message: SignalingMessage.hangup, sender: sender, sessionDetails: sessionDetails)
		case .reject: return (message: SignalingMessage.reject, sender: sender, sessionDetails: sessionDetails)
		case .userEnteredChatRoom:
			guard let roomName = params[SignalingParams.roomName.rawValue] as? String else {
				throw SignalingMessagesFactoryError.undefinedSignalingMessageType
			}
			return (message: SignalingMessage.user(enteredChatRoomName: roomName), sender: sender, sessionDetails: nil)
		}
		
		throw SignalingMessagesFactoryError.undefinedSignalingMessageType
	}
	
	private func compressedCustomParams(params: [String: AnyObject]) -> String? {
		let jsonRepresentation = try? NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions(rawValue: 0))
		let compressedParams = jsonRepresentation?.gzippedData()
		let base64Representation = compressedParams?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)
		return base64Representation
	}
}
