//
//  AuthStoryConfigurator.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class AuthStoryModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? AuthStoryViewController {
            configure(viewController)
        }
    }

    private func configure(viewController: AuthStoryViewController) {

        let router = AuthStoryRouter()

        let presenter = AuthStoryPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = AuthStoryInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}