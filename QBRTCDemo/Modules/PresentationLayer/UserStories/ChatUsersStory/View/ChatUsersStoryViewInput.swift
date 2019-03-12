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
	
	func showErrorMessage(_ message: String)
	
	/**
	Reload table view data
	*/
	func reloadDataWithUsers(_ users: [SVUser])
	
	func configureViewWithCurrentUser(_ user: SVUser)
}
