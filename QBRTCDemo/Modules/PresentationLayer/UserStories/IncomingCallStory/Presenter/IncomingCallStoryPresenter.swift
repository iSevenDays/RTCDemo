//
//  IncomingCallStoryPresenter.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

@objc class IncomingCallStoryPresenter: NSObject, IncomingCallStoryModuleInput, IncomingCallStoryViewOutput, IncomingCallStoryInteractorOutput{

    weak var view: IncomingCallStoryViewInput!
    var interactor: IncomingCallStoryInteractorInput!
    var router: IncomingCallStoryRouterInput!

    func viewIsReady() {
		view.setupInitialState()
    }
	
	// MARK: IncomingCallStoryModuleInput
	
	func configureModuleWithCallInitiator(opponent: SVUser) {
		interactor.setOpponent(opponent)
		view.configureViewWithCallInitiator(opponent)
	}
	
	// MARK: IncomingCallStoryViewOutput
	
	func didTriggerAcceptButtonTapped() {
		router.openVideoStoryWithOpponent(interactor.retrieveOpponent())
	}
	
	func didTriggerDeclineButtonTapped() {
		interactor.rejectCall()
		router.unwindToChatsUserStory()
	}
}
