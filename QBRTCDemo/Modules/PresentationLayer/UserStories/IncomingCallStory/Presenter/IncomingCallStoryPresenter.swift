//
//  IncomingCallStoryPresenter.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class IncomingCallStoryPresenter: IncomingCallStoryModuleInput, IncomingCallStoryViewOutput, IncomingCallStoryInteractorOutput{

    weak var view: IncomingCallStoryViewInput!
    var interactor: IncomingCallStoryInteractorInput!
    var router: IncomingCallStoryRouterInput!

    func viewIsReady() {

    }
	
	// MARK: IncomingCallStoryViewOutput
	
	func didTriggerAcceptButtonTapped() {
		
	}
}
