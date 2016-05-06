//
//  ChatUsersStoryPresenter.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class ChatUsersStoryPresenter: ChatUsersStoryModuleInput, ChatUsersStoryViewOutput, ChatUsersStoryInteractorOutput{

    weak var view: ChatUsersStoryViewInput!
    var interactor: ChatUsersStoryInteractorInput!
    var router: ChatUsersStoryRouterInput!

    func viewIsReady() {

    }
}
