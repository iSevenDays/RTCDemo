//
//  ImageGalleryStoryConfigurator.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/02/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class ImageGalleryStoryModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController) {

        if let viewController = viewInput as? ImageGalleryStoryViewController {
            configure(viewController)
        }
    }

    private func configure(viewController: ImageGalleryStoryViewController) {

        let router = ImageGalleryStoryRouter()

        let presenter = ImageGalleryStoryPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = ImageGalleryStoryInteractor()
        interactor.output = presenter
		interactor.callService = CallService()

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
