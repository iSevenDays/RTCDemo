//
//  ChatUsersStoryConfigurator.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class ChatUsersStoryModuleConfigurator {

    func configureModuleForViewInput(_ viewInput: ChatUsersStoryViewController) {
		configure(viewInput)
    }

    fileprivate func configure(_ viewController: ChatUsersStoryViewController) {

        let router = ChatUsersStoryRouter()
		router.transitionHandler = viewController
		
        let presenter = ChatUsersStoryPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = ChatUsersStoryInteractor()
        interactor.output = presenter
		interactor.cacheService = UserDefaults.standard as CacheServiceProtocol
		interactor.restService = ServicesProvider.currentProvider.restService
		interactor.callService = ServicesProvider.currentProvider.callService
		
		ServicesProvider.currentProvider.callService.addObserver(interactor)
		
        presenter.interactor = interactor
        viewController.output = presenter
		viewController.alertControl = AlertControl()
    }

}
