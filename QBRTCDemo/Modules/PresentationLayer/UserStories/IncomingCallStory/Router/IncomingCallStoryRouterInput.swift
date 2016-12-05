//
//  IncomingCallStoryRouterInput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol IncomingCallStoryRouterInput {
	func openVideoStoryWithOpponent(opponent: SVUser)
	
	// When call is declined
	func unwindToChatsUserStory()
}
