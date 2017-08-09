//
//  LYRMLayerControllerTest.m
//  XDK Messenger
//
//  Created by Kevin Coleman on 1/20/15.
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

@class LYRUIConfiguration;

@interface LYRMLayerControllerTest : KIFTestCase

@property (nonatomic) LYRMTestInterface *testInterface;
@property (nonatomic) LYRMTestUser *testUser;

@end

@implementation LYRMLayerControllerTest

- (void)setUp
{
    [super setUp];
    LYRMLayerController *applicationController =  [(LYRMAppDelegate *)[[UIApplication sharedApplication] delegate] layerController];
    self.testInterface = [LYRMTestInterface testInterfaceWithApplicationController:applicationController];
}

- (void)tearDown
{
    [self.testInterface deauthenticateIfNeeded];
    [super tearDown];
}

- (void)testToVerifyApplicationGlobalResourcesOnInitialization
{
    expect(self.testInterface.applicationController.layerClient).toNot.beNil;
    expect(self.testInterface.applicationController.layerClient).to.beKindOf([LYRClient class]);
    
    expect(self.testInterface.applicationController.APIManager).toNot.beNil;
    expect(self.testInterface.applicationController.APIManager).to.beKindOf([LYRMAPIManager class]);
    
    expect(self.testInterface.applicationController.persistenceManager).toNot.beNil;
    expect(self.testInterface.applicationController.persistenceManager).to.beKindOf([LYRMPersistenceManager class]);
}

@end
