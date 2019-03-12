//
//  IncomingCallStoryInteractor.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class IncomingCallStoryInteractor: IncomingCallStoryInteractorInput {

    weak var output: IncomingCallStoryInteractorOutput!
	internal weak var callService: CallServiceProtocol!
	
	internal var opponent: SVUser!
	
	// MARK: IncomingCallStoryInteractorInput
	
	/// Set opponent, initiator of a call
	func setOpponent(_ opponent: SVUser) {
		self.opponent = opponent
	}
	
	func retrieveOpponent() -> SVUser {
		return opponent
	}
	
	func rejectCall() {
		do {
			try callService.sendRejectCallToOpponent(opponent)
		} catch CallServiceError.canNotRejectCallWithoutPendingOffer {
			NSLog("%@", "Error call service can not reject call without pending offer")
		} catch let error {
			NSLog("%@", "Error starting a call with user \(error)")
		}
	}
	
	func stopHandlingEvents() {
		callService.removeObserver(self)
	}
}

extension IncomingCallStoryInteractor: CallServiceObserver {
	func callService(_ callService: CallServiceProtocol, didReceiveHangupFromOpponent opponent: SVUser) {
		if self.opponent == opponent {
			output.didReceiveHangupForIncomingCall()
		}
	}
}
