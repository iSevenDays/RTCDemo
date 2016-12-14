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
	func setOpponent(opponent: SVUser) {
		self.opponent = opponent
	}
	
	func retrieveOpponent() -> SVUser {
		return opponent
	}
	
	func rejectCall() {
		callService.sendRejectCallToOpponent(opponent)
	}
}
