//
//  ChatUsersStoryConfigurator.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class ChatUsersStoryModuleConfigurator {

    func configureModuleForViewInput(viewInput: ChatUsersStoryViewController) {
		configure(viewInput)
    }

    private func configure(viewController: ChatUsersStoryViewController) {

        let router = ChatUsersStoryRouter()
		router.transitionHandler = viewController
		
        let presenter = ChatUsersStoryPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = ChatUsersStoryInteractor()
        interactor.output = presenter
		interactor.cacheService = NSUserDefaults.standardUserDefaults()
		interactor.restService = ServicesProvider.currentProvider.restService
		
		ServicesProvider.currentProvider.callService.addDelegate(interactor)
		
        presenter.interactor = interactor
        viewController.output = presenter
    }

}
