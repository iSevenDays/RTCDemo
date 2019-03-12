//
//  IncomingCallStoryPresenter.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class IncomingCallStoryPresenter: NSObject {

    weak var view: IncomingCallStoryViewInput!
    var interactor: IncomingCallStoryInteractorInput!
    var router: IncomingCallStoryRouterInput!
}

extension IncomingCallStoryPresenter: IncomingCallStoryModuleInput {
	func configureModuleWithCallInitiator(_ opponent: SVUser) {
		interactor.setOpponent(opponent)
		view.configureViewWithCallInitiator(opponent)
	}
}


extension IncomingCallStoryPresenter: IncomingCallStoryViewOutput {
	func viewIsReady() {
		view.setupInitialState()
	}
	
	func didTriggerAcceptButtonTapped() {
		router.openVideoStoryWithOpponent(interactor.retrieveOpponent())
		interactor.stopHandlingEvents()
		view.hideView()
	}
	
	func didTriggerDeclineButtonTapped() {
		interactor.rejectCall()
		router.unwindToChatsUserStory()
	}
	
	func didTriggerCloseAction() {
		router.unwindToChatsUserStory()
	}
}


extension IncomingCallStoryPresenter: IncomingCallStoryInteractorOutput {
	func didReceiveHangupForIncomingCall() {
		view.showOpponentDecidedToDeclineCall()
	}
}
