//
//  IncomingCallStoryRouterInput.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol IncomingCallStoryRouterInput {
	func openVideoStoryWithInitiator(initiator: SVUser, thenCallOpponent opponent: SVUser)
}
