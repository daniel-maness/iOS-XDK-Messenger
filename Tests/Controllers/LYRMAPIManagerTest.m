//
//  LYRMAPIManagerTest.m
//  XDK Messenger
//
//  Created by Kevin Coleman on 6/30/14.
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

#import "LYRMAPIManager.h"
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import "LYRMUtilities.h"
#import "LYRMPersistenceManager.h"
#import "LYRCountdownLatch.h"
#import "LYRMAppDelegate.h"
#import "LYRMTestUser.h"
#import "LYRMTestInterface.h"

@interface LYRMAPIManagerTest : XCTestCase

@property (nonatomic) LYRMTestInterface *testInterface;

@end

@implementation LYRMAPIManagerTest

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

- (void)testRaisesOnAttempToInitx
{
    expect(^{ [LYRMAPIManager new]; }).to.raise(NSInternalInconsistencyException);
}

- (void)testInitializingAPIManager
{
    LYRMAPIManager *manager = [LYRMAPIManager managerWithBaseURL:[NSURL URLWithString:@"http://baseURLstring"] layerClient:self.testInterface.applicationController.layerClient];
    expect(manager).toNot.beNil();
}

@end
