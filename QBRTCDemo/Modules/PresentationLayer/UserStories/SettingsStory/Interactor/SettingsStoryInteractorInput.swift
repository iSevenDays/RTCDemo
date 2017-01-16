//
//  SettingsStorySettingsStoryInteractorInput.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/01/2017.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol SettingsStoryInteractorInput {
 	/**
	Request available settings
	output will be notified with didReceiveSettings:
	*/
	func requestSettings()
	
	/**
	Process SettingModel and depending on setting type
	notify output
	
	Currently only switcher setting model is supported
	*/
	func handleSettingModelSelected(settingModel: SettingModel)
}
