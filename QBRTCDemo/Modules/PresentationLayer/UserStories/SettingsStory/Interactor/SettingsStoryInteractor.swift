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
		var videoSettings: [SettingModel] = []
		
		let selectedVideoSetting = settingsStorage.videoSetting
		
		for videoSettingType in VideoQualitySetting.allValues {
			var subLabel = ""
			switch videoSettingType {
			case .low: subLabel = "Best for slow internet connection"
			case .medium: subLabel = "Best for 3G internet connection"
			case .high: subLabel = "Best for fast 3G or Wi-Fi internet connection"
			default: NSLog("%@", "Error undefined video type")
			}
			let setting = SettingModel(type: .subtitle(label: videoSettingType.rawValue, subLabel: subLabel, selected: videoSettingType == selectedVideoSetting))
			videoSettings.append(setting)
		}
		
		let videoSettingsSection = SettingsSection(name: "Video Quality", settings: videoSettings)
		return [videoSettingsSection]
	}
}

extension SettingsStoryInteractor: SettingsStoryInteractorInput {
	func requestSettings() {
		output?.didReceiveSettings(settings())
	}
	
	// TODO: implement UUID for SettingItem and SettingsStorage setting
	// to connect between model and SettingsStorage
	func handleSettingModelSelected(_ settingModel: SettingModel) {
		switch settingModel.type {
		case let .subtitle(label: label, subLabel: _, selected: _):
			guard let videoSetting = VideoQualitySetting(rawValue: label) else {
				NSLog("%@", "Error unknown video setting type")
				return
			}
			settingsStorage.videoSetting = videoSetting
		}
		
		output?.didReceiveSettings(settings())
	}
}
