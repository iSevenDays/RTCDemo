//
//  VideoCallStoryViewOutput.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

@objc protocol VideoCallStoryViewOutput {

    /**
        @author Anton Sokolchenko
        Notify presenter that view is ready
    */

    func viewIsReady()
	
	func didTriggerHangupButtonTapped()
	
	func didTriggerDataChannelButtonTapped()
	
	func didTriggerCloseButtonTapped()
	
	func didTriggerSwitchButtonTapped()
}
