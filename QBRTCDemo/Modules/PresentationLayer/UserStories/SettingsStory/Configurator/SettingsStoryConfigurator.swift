//
//  SettingsStorySettingsStoryConfigurator.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/01/2017.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

import UIKit

class SettingsStoryModuleConfigurator {

    func configureModuleForViewInput(_ viewInput: SettingsStoryViewController) {
		configure(viewInput)
    }

    fileprivate func configure(_ viewController: SettingsStoryViewController) {

        let router = SettingsStoryRouter()

        let presenter = SettingsStoryPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = SettingsStoryInteractor()
        interactor.output = presenter
		interactor.settingsStorage = ServicesProvider.currentProvider.settingsStorage
		
        presenter.interactor = interactor
        viewController.output = presenter
    }
}
