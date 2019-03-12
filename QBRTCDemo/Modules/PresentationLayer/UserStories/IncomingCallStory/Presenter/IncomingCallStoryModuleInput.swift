//
//  IncomingCallStoryModuleInput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

@objc protocol IncomingCallStoryModuleInput: RamblerViperModuleInput {
	
	func configureModuleWithCallInitiator(_ opponent: SVUser)
}
