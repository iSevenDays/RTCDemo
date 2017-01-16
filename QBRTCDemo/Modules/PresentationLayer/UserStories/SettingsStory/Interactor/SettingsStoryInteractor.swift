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

}

extension SettingsStoryInteractor: SettingsStoryInteractorInput {
	func requestFullHDVideoQualityStatus() {
		output?.didReceiveFullHDVideoQualityEnabled(settingsStorage.fullHDVideoQualityEnabled)
	}
	
	func requestFullHDVideoQualityEnabled(enabled: Bool) {
		settingsStorage.fullHDVideoQualityEnabled = enabled
		output?.didReceiveFullHDVideoQualityEnabled(enabled)
	}
}
