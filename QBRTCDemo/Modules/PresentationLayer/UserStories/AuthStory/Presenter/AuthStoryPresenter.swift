//
//  AuthStoryPresenter.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class AuthStoryPresenter: AuthStoryModuleInput, AuthStoryViewOutput, AuthStoryInteractorOutput{

    weak var view: AuthStoryViewInput!
    var interactor: AuthStoryInteractorInput!
    var router: AuthStoryRouterInput!

    func viewIsReady() {

    }
}
