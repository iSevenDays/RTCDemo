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
	
	func settings() -> [SettingsSection] {
		
		let videoSettingLow = SettingModel(type: .subtile(label: VideoQualitySetting.low.rawValue, subLabel: "Use when you have slow internet connection", selected: false))
		let videoSettingMedium = SettingModel(type: .subtile(label: VideoQualitySetting.medium.rawValue, subLabel: "Use when you have 3G internet connection", selected: false))
		let videoSettingHigh = SettingModel(type: .subtile(label: VideoQualitySetting.high.rawValue, subLabel: "Use when you have fast 3G or Wi-Fi internet connection", selected: false))
		
		let videoSettings = SettingsSection(name: "Video Quality", settings: [videoSettingLow, videoSettingMedium, videoSettingHigh])
		return [videoSettings]
	}
	
}

extension SettingsStoryInteractor: SettingsStoryInteractorInput {
	func requestSettings() {
		output?.didReceiveSettings(settings())
	}
	
	// TODO: implement UUID for SettingItem and SettingsStorage setting
	// to connect between model and SettingsStorage
	func handleSettingModelSelected(settingModel: SettingModel) {
//		let allSettings = settings()
//		if let settingIndex = allSettings.values.indexOf(settingModel) {
//			let setting = allSettings[settingIndex]
//			switch setting.type {
//			case let .subtile(label: label, subLabel: subLabel, selected: selected):
//				settingsStorage.fullHDVideoQualityEnabled = false
//			}
//		}
		
		output?.didReceiveSettings(settings())
	}
}
