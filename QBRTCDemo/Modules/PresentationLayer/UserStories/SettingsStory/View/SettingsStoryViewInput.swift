//
//  SettingsStorySettingsStoryViewInput.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/01/2017.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

protocol SettingsStoryViewInput: class {

    /**
        @author Anton Sokolchenko
        Setup initial state of the view
    */

    func setupInitialState()
	
	func showFullHDVideoQualityEnabled(enabled: Bool)
}
