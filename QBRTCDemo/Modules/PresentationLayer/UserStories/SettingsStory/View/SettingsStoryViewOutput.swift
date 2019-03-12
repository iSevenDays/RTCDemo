//
//  SettingsStorySettingsStoryViewOutput.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/01/2017.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

@objc protocol SettingsStoryViewOutput {

    /**
        @author Anton Sokolchenko
        Notify presenter that view is ready
    */

    func viewIsReady()
	
	func didSelectSettingModel(_ settingModel: SettingModel)
}
