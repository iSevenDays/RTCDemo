//
//  IncomingCallStoryInteractor.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class IncomingCallStoryInteractor: IncomingCallStoryInteractorInput {

    weak var output: IncomingCallStoryInteractorOutput!

	private(set) var initiator: SVUser!
	private(set) var opponent: SVUser!
	
	// MARK: IncomingCallStoryInteractorInput
	
	func setOpponent(opponent: SVUser) {
		self.opponent = opponent
	}
	
	func retrieveOpponent() -> SVUser {
		return opponent
	}
}
