//
//  ChatUsersStoryViewInput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

protocol ChatUsersStoryViewInput: class {

    /**
        @author Anton Sokolchenko
        Setup initial state of the view
    */

    func setupInitialState()
	
	func showErrorMessage(message: String)
	
	/**
	Reload table view data
	*/
	func reloadDataWithUsers(users: [SVUser])
	
	func configureViewWithCurrentUser(user: SVUser)
}
