//
//  ChatUsersStoryViewInput.swift
//  QBRTCDemo
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
	
	
	/**
	Reload table view data
	*/
	func reloadData()
}
