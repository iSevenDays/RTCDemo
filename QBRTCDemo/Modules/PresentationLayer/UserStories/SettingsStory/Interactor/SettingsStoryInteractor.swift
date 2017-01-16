//
//  SettingsStorySettingsStoryInteractor.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/01/2017.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

class SettingsStoryInteractor {

    weak var output: SettingsStoryInteractorOutput?
	weak var settingsStorage: SettingsStorage!
	
	func settings() -> [SettingModel]{
		
		let fullHDVideoQualitySetting = SettingModel(label: "Prefer FullHD Video Quality", type: .switcher(enabled: settingsStorage.fullHDVideoQualityEnabled))
		
		return [fullHDVideoQualitySetting]
	}
	
}

extension SettingsStoryInteractor: SettingsStoryInteractorInput {
	func requestSettings() {
		output?.didReceiveSettings(settings())
	}
	
	// TODO: implement UUID for SettingItem and SettingsStorage setting
	// to connect between model and SettingsStorage
	func handleSettingModelSelected(settingModel: SettingModel) {
		let allSettings = settings()
		if let settingIndex = allSettings.indexOf(settingModel) {
			let setting = allSettings[settingIndex]
			switch setting.type {
			case let .switcher(enabled: enabled):
				settingsStorage.fullHDVideoQualityEnabled = enabled
			}
		}
		
		output?.didReceiveSettings(settings())
	}
}
