//
//  AuthStoryViewInput.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

protocol AuthStoryViewInput: class {

    /**
        @author Anton Sokolchenko
        Setup initial state of the view
    */

    func setupInitialState()
	
	func enableInput()
	func disableInput()
	
	func setUserName(userName: String)
	func setRoomName(roomName: String)
	
	/**
	Retrieve UserName and RoomName
	*/
	func retrieveInformation()
	
	func showIndicatorLoggingIn()
	func showIndicatorSigningUp()
	
	func showErrorLogin()
}
