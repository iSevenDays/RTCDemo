//
//  VideoCallStoryConfigurator.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class VideoCallStoryModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(_ viewInput: UIViewController) {

        if let viewController = viewInput as? VideoCallStoryViewController {
            configure(viewController)
        }
    }

    fileprivate func configure(_ viewController: VideoCallStoryViewController) {

        let router = VideoCallStoryRouter()
		router.transitionHandler = viewController
		
        let presenter = VideoCallStoryPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = VideoCallStoryInteractor()
        interactor.output = presenter
		interactor.callService = ServicesProvider.currentProvider.callService
		interactor.pushService = ServicesProvider.currentProvider.pushService
		interactor.permissionsService = ServicesProvider.currentProvider.permissionsService
		
        presenter.interactor = interactor
        viewController.output = presenter
		viewController.alertControl = AlertControl()
    }

}
