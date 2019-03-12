//
//  SettingsStorySettingsStoryPresenter.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/01/2017.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

class SettingsStoryPresenter: NSObject {

    weak var view: SettingsStoryViewInput?
    var interactor: SettingsStoryInteractorInput!
    var router: SettingsStoryRouterInput!

    func viewIsReady() {
		view?.setupInitialState()
		interactor.requestSettings()
    }
	
}

extension SettingsStoryPresenter: SettingsStoryModuleInput {
	
}

extension SettingsStoryPresenter: SettingsStoryViewOutput {
	func didSelectSettingModel(_ settingModel: SettingModel) {
		interactor.handleSettingModelSelected(settingModel)
	}
}

extension SettingsStoryPresenter: SettingsStoryInteractorOutput {
	func didReceiveSettings(_ settings: [SettingsSection]) {
		view?.reloadSettings(settings)
	}
}

