//
//  AuthStoryRouterInput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol AuthStoryRouterInput {
	func openChatUsersStoryWithTag(tag: String, currentUser: SVUser)
}
