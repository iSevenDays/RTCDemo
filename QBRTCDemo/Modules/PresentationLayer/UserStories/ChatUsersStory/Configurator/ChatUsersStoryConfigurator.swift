//
//  ChatUsersStoryConfigurator.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class ChatUsersStoryModuleConfigurator {

    func configureModuleForViewInput<UITableViewController>(viewInput: UITableViewController) {

        if let viewController = viewInput as? ChatUsersStoryTableViewController {
            configure(viewController)
        }
    }

    private func configure(viewController: ChatUsersStoryTableViewController) {

        let router = ChatUsersStoryRouter()

        let presenter = ChatUsersStoryPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = ChatUsersStoryInteractor()
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
