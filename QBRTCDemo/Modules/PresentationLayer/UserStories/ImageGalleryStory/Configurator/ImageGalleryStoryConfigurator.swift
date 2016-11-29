//
//  ImageGalleryStoryConfigurator.swift
//  RTCDemo
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
		interactor.callService = ServicesProvider.currentProvider.callService
        interactor.output = presenter
		
        presenter.interactor = interactor
        viewController.output = presenter
		
		let imagesInteractor = ImageGalleryStoryCollectionViewInteractor()
		imagesInteractor.output = presenter
		
		interactor.imagesOutput = imagesInteractor
		
		interactor.collectionViewConfigurationBlock = {
			collectionView in
			
			collectionView.interactor = imagesInteractor
			
			collectionView.dataSource = collectionView.interactor
			collectionView.delegate = collectionView.interactor
			collectionView.collectionViewLayout.invalidateLayout()
		}
    }

}
