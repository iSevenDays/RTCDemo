//
//  AuthStoryViewOutput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

protocol AuthStoryViewOutput {

    /**
        @author Anton Sokolchenko
        Notify presenter that view is ready
    */

    func viewIsReady()
	
	func didTriggerLoginButtonTapped(userName: String, roomName: String)
	
	/**
	Triggered by retrieveInformation method
	*/
	func didReceiveUserName(userName: String, roomName: String)
}
