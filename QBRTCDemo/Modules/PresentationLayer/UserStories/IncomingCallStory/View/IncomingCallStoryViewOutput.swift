//
//  IncomingCallStoryViewOutput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

@objc protocol IncomingCallStoryViewOutput {

    /**
        @author Anton Sokolchenko
        Notify presenter that view is ready
    */
    func viewIsReady()
	
	func didTriggerAcceptButtonTapped()
	func didTriggerDeclineButtonTapped()
	
    /**
	Called only in one case - when an opponent sent hanup message for incoming call
	It means that the opponent decided to decline the call
	*/
	func didTriggerCloseAction()
}
