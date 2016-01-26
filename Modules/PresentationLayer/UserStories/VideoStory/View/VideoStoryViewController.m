//
//  VideoStoryViewController.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import "VideoStoryViewController.h"

#import "VideoStoryViewOutput.h"

@implementation VideoStoryViewController

#pragma mark - Методы жизненного цикла

- (void)viewDidLoad {
	[super viewDidLoad];

	[self.output didTriggerViewReadyEvent];
}

#pragma mark - VideoStoryViewInput methods

- (void)setupInitialState {
	// В этом методе происходит настройка параметров view, зависящих от ее жизненого цикла (создание элементов, анимации и пр.)
}

- (void)configureViewWithUser1 {
	self.btnConnectWithUser1.backgroundColor = [UIColor greenColor];
}

- (void)configureViewWithUser2 {
	self.btnConnectWithUser2.backgroundColor = [UIColor greenColor];
}

- (void)showErrorConnect {
	[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot connect" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - VideoStoryViewOutput methods

- (IBAction)didTapButtonConnectWithUser1:(id)sender {
	[self.output didTriggerConnectWithUser1ButtonTaped];
}

- (IBAction)didTapButtonConnectWithUser2:(id)sender {
	[self.output didTriggerConnectWithUser2ButtonTaped];
}

- (IBAction)didTapButtonStartCall:(id)sender {
	[self.output didTriggerStartCallButtonTaped];
}

- (IBAction)didTapButtonHangup:(id)sender {
	[self.output didTriggerHangupButtonTaped];
}


@end