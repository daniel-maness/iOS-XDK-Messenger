//
//  LYRMConversationViewControllerTest.m
//  XDK Messenger
//
//  Created by Kevin Coleman on 1/15/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <KIF/KIF.h>
#import <KIFViewControllerActions/KIFViewControllerActions.h>
#import <XCTest/XCTest.h>

#import "LYRMLayerController.h"
#import "LYRMTestInterface.h"
#import "LYRMTestUser.h"

extern NSString *const LYRMConversationListTableViewAccessibilityLabel;
extern NSString *const LYRMConversationViewControllerAccessibilityLabel;
extern NSString *const ATLAddressBarAccessibilityLabel;
extern NSString *const LYRMSettingsButtonAccessibilityLabel;
extern NSString *const LYRMComposeButtonAccessibilityLabel;
extern NSString *const LYRMSettingsViewControllerTitle;

@interface LYRMConversationListViewControllerTest : KIFTestCase

@property (nonatomic) LYRMTestInterface *testInterface;

@end

@implementation LYRMConversationListViewControllerTest

- (void)setUp
{
    [super setUp];
    
    LYRMLayerController *applicationController =  [(LYRMAppDelegate *)[[UIApplication sharedApplication] delegate] layerController];
    self.testInterface = [LYRMTestInterface testInterfaceWithApplicationController:applicationController];
    [self.testInterface connectLayerClient];
    [self.testInterface deauthenticateIfNeeded];
    [self.testInterface registerTestUserWithIdentifier:@"test"];
}

- (void)tearDown
{
    [self.testInterface clearLayerContent];
    [tester waitForTimeInterval:1];
    [self.testInterface deauthenticateIfNeeded];
    [super tearDown];
}

- (void)testToVerifyConversationListViewControllerUI
{
    [tester waitForViewWithAccessibilityLabel:LYRMSettingsButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LYRMComposeButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LYRMConversationListTableViewAccessibilityLabel];
}

- (void)testToVerifySettingsButtonFunctionality
{
    [tester tapViewWithAccessibilityLabel:LYRMSettingsButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:LYRMSettingsViewControllerTitle];
}

- (void)testToVerifyComposeButtonFunctionality
{
    [tester tapViewWithAccessibilityLabel:LYRMComposeButtonAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
}

- (void)testToVerifyConversationSelectionFunctionality
{
    NSString *testUserName = @"Blake";
    __block NSSet *participant;
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.testInterface.applicationController.persistenceManager performUserSearchWithString:testUserName completion:^(NSArray *users, NSError *error) {
        LYRMUser *user = users.firstObject;
        participant = [NSSet setWithObject:user.participantIdentifier];
        [latch decrementCount];
    }];

    [self.testInterface.contentFactory newConversationsWithParticipants:participant];
    [tester waitForViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:participant]];
    
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:participant]];
    [tester waitForViewWithAccessibilityLabel:LYRMConversationViewControllerAccessibilityLabel];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:ATLAddressBarAccessibilityLabel];
}

- (void)testToVerifyAllConversationDisplayInConversationList
{
    NSSet *participants = [NSSet setWithObject:@"0"];
    [self.testInterface.contentFactory newConversationsWithParticipants:participants];
    [self.testInterface.contentFactory newConversationsWithParticipants:participants];
    [self.testInterface.contentFactory newConversationsWithParticipants:participants];
    [self.testInterface.contentFactory newConversationsWithParticipants:participants];
    [self.testInterface.contentFactory newConversationsWithParticipants:participants];
    
    UITableView *conversationTableView =  (UITableView *)[tester waitForViewWithAccessibilityLabel:LYRMConversationListTableViewAccessibilityLabel];
    expect([conversationTableView numberOfRowsInSection:0]).to.equal(5);
    expect(conversationTableView.numberOfSections).to.equal(1);
}

@end
