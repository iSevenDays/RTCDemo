//
//  ChatUsersStoryModuleInput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

@objc protocol ChatUsersStoryModuleInput: RamblerViperModuleInput {
	
	func setTag(tag: String, currentUser: SVUser)
}
