//
//  LYRMConversationDetailViewControllerTest.m
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
#import <KIFViewControllerActions/KIFSystemTestActor+ViewControllerActions.h>

#import "LYRMLayerController.h"
#import "LYRMTestInterface.h"
#import "LYRMTestUser.h"

#import "LYRMConversationDetailViewController.h"

extern NSString *const LYRMConversationDetailTableViewAccessibilityLabel;
extern NSString *const LYRMConversationDetailViewControllerTitle;
extern NSString *const LYRMAddParticipantsAccessibilityLabel;
extern NSString *const LYRMConversationListTableViewAccessibilityLabel;
extern NSString *const LYRMDetailsButtonAccessibilityLabel;
extern NSString *const LYRMConversationNamePlaceholderText;
extern NSString *const LYRMShareLocationText;
extern NSString *const LYRMDeleteConversationText;
extern NSString *const LYRMLeaveConversationText;

@interface LYRMConversationDetailViewControllerTest : KIFTestCase

@property (nonatomic) LYRConversation *conversation;
@property (nonatomic) LYRMTestInterface *testInterface;
@property (nonatomic) LYRMTestUser *participant;
@property (nonatomic) NSSet *participantIdentifiers;

@end

@implementation LYRMConversationDetailViewControllerTest

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

- (void)testToVerifyConversationDetailViewControllerUI
{
    [self setup1on1Conversation];

    LYRMConversationDetailViewController *controller = [LYRMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];
    UITableView *tableView = (UITableView *)[tester waitForViewWithAccessibilityLabel:LYRMConversationDetailTableViewAccessibilityLabel ];
    expect(tableView.numberOfSections).to.equal(4);
}


- (void)testToVerifyAddingParticipantToA1on1Conversation
{
    [self setup1on1Conversation];
    
    LYRMConversationDetailViewController *controller = [LYRMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.applicationController = self.testInterface.applicationController;
    
    id delegateMock = OCMProtocolMock(@protocol(LYRMConversationDetailViewControllerDelegate));
    controller.detailDelegate = delegateMock;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];
    [tester waitForViewWithAccessibilityLabel:LYRMConversationDetailTableViewAccessibilityLabel];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        LYRConversation *conversation;
        [invocation getArgument:&conversation atIndex:3];
        expect(conversation).toNot.equal(self.conversation);
        expect(conversation.participants).toNot.contain(self.testInterface.applicationController.layerClient.authenticatedUserID);
        expect(conversation.participants.count).to.equal(self.conversation.participants.count);
    }] conversationDetailViewController:[OCMArg any] didChangeConversation:[OCMArg any]];

    [tester tapViewWithAccessibilityLabel:LYRMAddParticipantsAccessibilityLabel];
    [tester tapViewWithAccessibilityLabel:@"Blake XDK"];
    [delegateMock verify];
}

- (void)testToVerifyAddingParticipantToAGroupConversation
{
    [self setupGroupConversation];
    
    LYRMConversationDetailViewController *controller = [LYRMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.applicationController = self.testInterface.applicationController;
    
    id delegateMock = OCMProtocolMock(@protocol(LYRMConversationDetailViewControllerDelegate));
    controller.detailDelegate = delegateMock;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];
    [tester waitForViewWithAccessibilityLabel:LYRMConversationDetailTableViewAccessibilityLabel];
    
    [[delegateMock reject] conversationDetailViewController:[OCMArg any] didChangeConversation:[OCMArg any]];
    
    [tester tapViewWithAccessibilityLabel:LYRMAddParticipantsAccessibilityLabel];
    [tester tapViewWithAccessibilityLabel:@"Blake XDK"];
    [delegateMock verify];
}

- (void)testToVerifyRemovalOfParticipantInGroupConversation
{
    [self setupGroupConversation];
    
    LYRMConversationDetailViewController *controller = [LYRMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.applicationController = self.testInterface.applicationController;
    
    id delegateMock = OCMProtocolMock(@protocol(LYRMConversationDetailViewControllerDelegate));
    controller.detailDelegate = delegateMock;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];
    [tester waitForViewWithAccessibilityLabel:LYRMConversationDetailTableViewAccessibilityLabel];
    
    [[delegateMock reject] conversationDetailViewController:[OCMArg any] didChangeConversation:[OCMArg any]];
    
    LYRMUser *user = [self.testInterface userForIdentifier:@"0"];
    [tester waitForViewWithAccessibilityLabel:user.fullName];
    [tester swipeViewWithAccessibilityLabel:user.fullName inDirection:KIFSwipeDirectionLeft];
    [tester tapViewWithAccessibilityLabel:@"Remove"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:user.fullName];
    [delegateMock verify];
}


- (void)testToVerifyBlockingOfParticipantInGroupConversation
{
    [self removeExistingPolicies];
    [self setupGroupConversation];
    
    LYRMConversationDetailViewController *controller = [LYRMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.applicationController = self.testInterface.applicationController;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];
    [tester waitForViewWithAccessibilityLabel:LYRMConversationDetailTableViewAccessibilityLabel];
    
    LYRMUser *user = [self.testInterface userForIdentifier:@"0"];
    [tester swipeViewWithAccessibilityLabel:user.fullName inDirection:KIFSwipeDirectionLeft];
    [tester waitForViewWithAccessibilityLabel:@"Block"];
    [tester tapViewWithAccessibilityLabel:@"Block"];
    [tester waitForViewWithAccessibilityLabel:@"Blocked"];
    
    LYRPolicy *policy = self.testInterface.applicationController.layerClient.policies.firstObject;
    expect(policy).toNot.beNil;
    expect(policy.sentByUserID).to.equal(user.participantIdentifier);
}

- (void)testToVerifyUnBlockingOfParticipantInGroupConversation
{
    [self removeExistingPolicies];
    [self setupGroupConversation];
    
    LYRMUser *user = [self.testInterface userForIdentifier:@"0"];
    LYRPolicy *policy = [LYRPolicy policyWithType:LYRPolicyTypeBlock];
    policy.sentByUserID = user.participantIdentifier;
   
    NSError *error;
    [self.testInterface.applicationController.layerClient addPolicy:policy error:&error];
    expect(error).to.beNil;
    
    LYRMConversationDetailViewController *controller = [LYRMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.applicationController = self.testInterface.applicationController;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];
    [tester waitForViewWithAccessibilityLabel:LYRMConversationDetailTableViewAccessibilityLabel];
    
    
    [tester swipeViewWithAccessibilityLabel:user.fullName inDirection:KIFSwipeDirectionLeft];
    [tester waitForViewWithAccessibilityLabel:@"Unblock"];
    [tester tapViewWithAccessibilityLabel:@"Unblock"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Blocked"];
    
    NSOrderedSet *policies = self.testInterface.applicationController.layerClient.policies;
    expect(policies.count).to.beNil;
}

- (void)testToVeriyConversationDetailViewDelegateOnLocationShare
{
    [self setup1on1Conversation];
    
    LYRMConversationDetailViewController *controller = [LYRMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.applicationController = self.testInterface.applicationController;
    id delegateMock = OCMProtocolMock(@protocol(LYRMConversationDetailViewControllerDelegate));
    controller.detailDelegate = delegateMock;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];
    [tester waitForViewWithAccessibilityLabel:LYRMConversationDetailTableViewAccessibilityLabel];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        
    }] conversationDetailViewControllerDidSelectShareLocation:[OCMArg any]];
    
    [tester tapViewWithAccessibilityLabel:LYRMShareLocationText];
    [delegateMock verifyWithDelay:2];
}

- (void)testToVerifyConversationDeletionFunctionality
{
    [self setup1on1Conversation];
    
    LYRMConversationDetailViewController *controller = [LYRMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.applicationController = self.testInterface.applicationController;
    
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.conversation.participants]];
    [tester tapViewWithAccessibilityLabel:@"Details"];

    [tester tapViewWithAccessibilityLabel:LYRMDeleteConversationText];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:LYRMConversationDetailViewControllerTitle];
    [tester waitForViewWithAccessibilityLabel:LYRMConversationListTableViewAccessibilityLabel];
    
    expect(self.conversation.isDeleted).to.beTruthy;
}

- (void)testToVerifyLeaveConversationFunctionality
{
    [self setupGroupConversation];
    
    LYRMConversationDetailViewController *controller = [LYRMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.applicationController = self.testInterface.applicationController;
    
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:self.conversation.participants]];
    [tester tapViewWithAccessibilityLabel:@"Details"];
    
    [tester tapViewWithAccessibilityLabel:LYRMLeaveConversationText];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:LYRMConversationDetailViewControllerTitle];
    [tester waitForViewWithAccessibilityLabel:LYRMConversationListTableViewAccessibilityLabel];
    
    expect(self.conversation.participants).toNot.contain(self.testInterface.applicationController.layerClient.authenticatedUserID);
}

- (void)testToVerifyMetadataFunctionality
{
    [self setupGroupConversation];
    
    LYRMConversationDetailViewController *controller = [LYRMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation];
    controller.applicationController = self.testInterface.applicationController;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [system presentModalViewController:navigationController configurationBlock:nil];
    
    NSString *conversationName = @"New Name";
    [tester tapViewWithAccessibilityLabel:LYRMConversationNamePlaceholderText];
    [tester enterText:conversationName intoViewWithAccessibilityLabel:LYRMConversationNamePlaceholderText];
    [tester tapViewWithAccessibilityLabel:@"done"];
    
    [tester waitForViewWithAccessibilityLabel:conversationName];
    expect([self.conversation.metadata valueForKey:LYRMConversationMetadataNameKey]).to.equal(conversationName);
}

- (void)setup1on1Conversation
{
    NSSet *participants = [NSSet setWithObject:@"0"];
    self.conversation = [self.testInterface.contentFactory newConversationsWithParticipants:participants];
    [tester waitForViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:participants]];
}

- (void)setupGroupConversation
{
    NSSet *participants = [NSSet setWithObjects:@"0", @"3", nil];
    self.conversation = [self.testInterface.contentFactory newConversationsWithParticipants:participants];
    [tester waitForViewWithAccessibilityLabel:[self.testInterface conversationLabelForParticipants:participants]];
}

- (void)removeExistingPolicies
{
    [tester waitForTimeInterval:1];
    NSOrderedSet *policies = self.testInterface.applicationController.layerClient.policies;
    for (LYRPolicy *policy in policies) {
        NSError *error;
        [self.testInterface.applicationController.layerClient removePolicy:policy error:&error];
        expect(error).to.beNil;
    }
    expect(self.testInterface.applicationController.layerClient.policies).to.beNil;
}

@end
