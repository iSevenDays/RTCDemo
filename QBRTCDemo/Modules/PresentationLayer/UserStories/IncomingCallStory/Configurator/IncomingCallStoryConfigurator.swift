//
//  IncomingCallStoryConfigurator.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class IncomingCallStoryModuleConfigurator {

	func configureModuleForViewInput(viewInput: IncomingCallStoryViewController) {
		configure(viewInput)
	}

    private func configure(viewController: IncomingCallStoryViewController) {

        let router = IncomingCallStoryRouter()
		router.transitionHandler = viewController
		
        let presenter = IncomingCallStoryPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = IncomingCallStoryInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
