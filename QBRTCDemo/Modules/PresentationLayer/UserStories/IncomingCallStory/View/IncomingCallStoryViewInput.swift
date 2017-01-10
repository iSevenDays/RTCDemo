//
//  IncomingCallStoryViewInput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

protocol IncomingCallStoryViewInput: class {

    /**
        @author Anton Sokolchenko
        Setup initial state of the view
    */

    func setupInitialState()
	
	func configureViewWithCallInitiator(callInitiator: SVUser)
	
	func showOpponentDecidedToDeclineCall()
	
	/// Hide view, so the view will not be visible on dismiss
	// TODO: Add Tests
	func hideView()
}
