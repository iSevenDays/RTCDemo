//
//  SettingsStorySettingsStoryPresenter.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/01/2017.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

@objc class SettingsStoryPresenter: NSObject {

    weak var view: SettingsStoryViewInput!
    var interactor: SettingsStoryInteractorInput!
    var router: SettingsStoryRouterInput!

    func viewIsReady() {

    }
}

extension SettingsStoryPresenter: SettingsStoryModuleInput {
	
}

extension SettingsStoryPresenter: SettingsStoryViewOutput {
	
}

extension SettingsStoryPresenter: SettingsStoryInteractorOutput {
	
}

