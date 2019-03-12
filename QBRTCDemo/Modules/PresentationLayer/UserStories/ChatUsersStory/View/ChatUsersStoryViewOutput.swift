//
//  ChatUsersStoryViewOutput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

@objc protocol ChatUsersStoryViewOutput {

    /**
        @author Anton Sokolchenko
        Notify presenter that view is ready
    */

    func viewIsReady()
	
	/**
	Triggers tapped on user event (start call)
	
	- parameter user: SVUser instance
	*/
	func didTriggerUserTapped(_ user: SVUser)
	
	
	/**
	Request to open Settings Story
	*/
	func didTriggerSettingsButtonTapped()
}
