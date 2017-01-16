//
//  ChatUsersStoryRouterInput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol ChatUsersStoryRouterInput {
	func openVideoStoryWithInitiator(initiator: SVUser, thenCallOpponent opponent: SVUser)
	func openIncomingCallStoryWithOpponent(opponent: SVUser)
	func openSettingsStory()
}
