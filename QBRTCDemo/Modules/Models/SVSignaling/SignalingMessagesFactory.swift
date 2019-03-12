//
//  SignalingMessagesFactory.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation
//
enum SignalingMessagesFactoryError: Error {
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
	
	func qbMessageFromSignalingMessage(_ message: SignalingMessage, sender: SVUser, sessionDetails: SessionDetails?) throws -> QBChatMessage {
		var params: [String: AnyObject] = [:]
		
		// SVUser sender populating
		params[SignalingParams.senderLogin.rawValue] = sender.login as AnyObject
		params[SignalingParams.senderFullName.rawValue] = sender.fullName as AnyObject
		
		// SessionDetails populating
		if let sessionDetails = sessionDetails {
			params[SignalingParams.sessionID.rawValue] = sessionDetails.sessionID as AnyObject
			params[SignalingParams.membersIDs.rawValue] = sessionDetails.membersIDs.compactMap({String($0)}).joined(separator: ",") as AnyObject
			params[SignalingParams.initiatorID.rawValue] = String(sessionDetails.initiatorID) as AnyObject
		}
		switch message {
		case let .answer(sdp: sessionDescription):
			params[SignalingParams.type.rawValue] = SignalingMessageType.answer.rawValue as AnyObject
			params[SignalingParams.sdp.rawValue] = sessionDescription.sdp as AnyObject
			break
		case let .offer(sdp: sessionDescription):
			params[SignalingParams.type.rawValue] = SignalingMessageType.offer.rawValue as AnyObject
			params[SignalingParams.sdp.rawValue] = sessionDescription.sdp as AnyObject
			break
		case let .candidates(candidates: candidates):
			params[SignalingParams.type.rawValue] = SignalingMessageType.candidates.rawValue as AnyObject
			var candidatesDict: [[String: String]] = []
			for candidate in candidates {
				candidatesDict.append([
					SignalingParams.index.rawValue: String(candidate.sdpMLineIndex),
					SignalingParams.mid.rawValue: candidate.sdpMid!,
					SignalingParams.sdp.rawValue: candidate.sdp])
				
			}
			params[SignalingParams.candidates.rawValue] = candidatesDict as AnyObject
			
			break
		case .hangup:
			params[SignalingParams.type.rawValue] = SignalingMessageType.hangup.rawValue as AnyObject
			break
		case .reject:
			params[SignalingParams.type.rawValue] = SignalingMessageType.reject.rawValue as AnyObject
			break
		case let .user(enteredChatRoomName: roomName):
			params[SignalingParams.type.rawValue] = SignalingMessageType.userEnteredChatRoom.rawValue as AnyObject
			params[SignalingParams.roomName.rawValue] = roomName as AnyObject
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
	func signalingMessageFromQBMessage(_ message: QBChatMessage) throws -> (message: SignalingMessage, sender: SVUser, sessionDetails: SessionDetails?) {
		guard let base64Representation = message.customParameters[SignalingParams.compressedData.rawValue] as? String else {
			throw SignalingMessagesFactoryError.incorrectSignalingMessage(message: message)
		}

		guard let decodedBase64Data = Data(base64Encoded: base64Representation, options: Data.Base64DecodingOptions(rawValue: 0)) else {
			throw SignalingMessagesFactoryError.incorrectSignalingMessage(message: message)
		}
		guard let ungzippedData = (decodedBase64Data as NSData).gunzipped() else {
			throw SignalingMessagesFactoryError.failedToDecompressMessage(message: message)
		}
		guard let params = try JSONSerialization.jsonObject(with: ungzippedData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] else {
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
		let sender = SVUser(id: NSNumber(value: message.senderID), login: userLogin, fullName: userFullName, password: nil, tags: nil)
		
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
			guard let membersIDs = (params[SignalingParams.membersIDs.rawValue] as? String)?.components(separatedBy: ",").compactMap({UInt.init($0)}) else {
				throw SignalingMessagesFactoryError.missingMembersIDs
			}
			sessionDetails = SessionDetails(initiatorID: UInt(initiatorID)!, membersIDs: membersIDs, sessionID: sessionID)
		case .userEnteredChatRoom: break
		}
		
		switch signalingMessageType {
		case .answer, .offer:
			guard let sourceSDP = params[SignalingParams.sdp.rawValue]?.replacingOccurrences(of: "&#13;", with: "\r") else {
				throw SignalingMessagesFactoryError.missingSDP
			}
			
			if signalingMessageType == .offer {
				let sdp = RTCSessionDescription(type: .offer, sdp: sourceSDP)
				return (message: SignalingMessage.offer(sdp: sdp), sender: sender, sessionDetails: sessionDetails)
			} else if signalingMessageType == .answer {
				let sdp = RTCSessionDescription(type: .answer, sdp: sourceSDP)
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
				guard let candidateSDP = candidate[SignalingParams.sdp.rawValue]?.replacingOccurrences(of: "&#13;", with: "\r") else {
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
	
	fileprivate func compressedCustomParams(_ params: [String: AnyObject]) -> String? {
		let jsonRepresentation = try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions(rawValue: 0))
		let compressedParams = (jsonRepresentation as NSData?)?.gzipped()
		let base64Representation = compressedParams?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithLineFeed)
		return base64Representation
	}
}
