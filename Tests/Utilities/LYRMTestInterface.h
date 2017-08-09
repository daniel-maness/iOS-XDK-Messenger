//
//  ATLTestInterface.h
//  XDK Messenger
//
//  Created by Kevin Coleman on 9/3/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
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

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "LYRMLayerController.h"
#import "LYRMLayerContentFactory.h"
#import "LYRMAppDelegate.h"
#import "LYRMTestUser.h"

// Testing Imports
#import <OCMock/OCMock.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import <LYRCountDownLatch/LYRCountDownLatch.h>
#import <KIF/KIF.h>
#import <KIFViewControllerActions/KIFViewControllerActions.h>
#import "LYRMUtilities.h"

@interface LYRMTestInterface : NSObject

+ (instancetype)testInterfaceWithApplicationController:(LYRMLayerController *)applicationController;

@property (nonatomic) LYRMLayerController *applicationController;

@property LYRMLayerContentFactory *contentFactory;

//-------------------------------
// Authentication Methods
//-------------------------------

- (void)connectLayerClient;

- (void)registerTestUserWithIdentifier:(NSString *)identifier;

- (void)deauthenticateIfNeeded;

- (void)clearLayerContent;

- (LYRMUser *)userForIdentifier:(NSString *)identifier;

//-------------------------------
// Accessibility Label Methods
//-------------------------------

- (NSString *)conversationLabelForParticipants:(NSSet *)participantIDs;

- (NSString *)selectionIndicatorAccessibilityLabelForUser:(LYRMUser *)testUser;

@end
