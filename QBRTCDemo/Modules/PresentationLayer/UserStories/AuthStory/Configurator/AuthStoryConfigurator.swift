//
//  AuthStoryConfigurator.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class AuthStoryModuleConfigurator {

    func configureModuleForViewInput(viewInput: AuthStoryViewController) {
		configure(viewInput)
    }

    private func configure(viewController: AuthStoryViewController) {

        let router = AuthStoryRouter()
		router.transitionHandler = viewController
		
        let presenter = AuthStoryPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = AuthStoryInteractor()
        interactor.output = presenter
		interactor.restService = ServicesProvider.currentProvider.restService
		interactor.callService = ServicesProvider.currentProvider.callService

        presenter.interactor = interactor
        viewController.output = presenter
		viewController.alertControl = AlertControl()
    }
}
