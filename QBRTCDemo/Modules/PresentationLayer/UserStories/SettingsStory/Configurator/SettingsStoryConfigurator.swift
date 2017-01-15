//
//  SettingsStorySettingsStoryConfigurator.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/01/2017.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

import UIKit

class SettingsStoryModuleConfigurator {

    func configureModuleForViewInput(viewInput: SettingsStoryViewController) {
		configure(viewInput)
    }

    private func configure(viewController: SettingsStoryViewController) {

        let router = SettingsStoryRouter()

        let presenter = SettingsStoryPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = SettingsStoryInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }
}
