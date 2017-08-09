//
//  LYRMConversationDetailViewController.m
//  XDK Messenger
//
//  Created by Kevin Coleman on 10/2/14.
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

#import <SVProgressHUD/SVProgressHUD.h>
#import "LYRMConversationDetailViewController.h"
#import "LYRMParticipantTableViewController.h"
#import "LYRMUtilities.h"

#import "LYRUIConfiguration.h"
#import "LYRUIIdentityListView.h"
#import "LYRUIListSection.h"
#import "LYRUIListDelegate.h"

typedef NS_ENUM(NSInteger, LYRMConversationDetailTableSection) {
    LYRMConversationDetailTableSectionMetadata,
    LYRMConversationDetailTableSectionParticipants,
    LYRMConversationDetailTableSectionLocation,
    LYRMConversationDetailTableSectionLeave,
    LYRMConversationDetailTableSectionCount,
};

typedef NS_ENUM(NSInteger, LYRMActionSheetTag) {
    LYRMActionSheetBlockUser,
    LYRMActionSheetLeaveConversation,
};

@interface LYRMConversationDetailViewController ()

@property (nonatomic) LYRUIConfiguration *layerUIConfiguration;
@property (nonatomic) LYRConversation *conversation;
@property (nonatomic) NSMutableArray *participants;

@end

@implementation LYRMConversationDetailViewController

NSString *const LYRMConversationDetailViewControllerTitle = @"Details";
NSString *const LYRMConversationMetadataNameKey = @"conversationName";

+ (instancetype)conversationDetailViewControllerWithConversation:(LYRConversation *)conversation withLayerUIConfiguration:(LYRUIConfiguration *)layerUIConfiguration {
    return [[self alloc] initWithConversation:conversation withLayerUIConfiguration:layerUIConfiguration];
}

- (id)initWithConversation:(LYRConversation *)conversation withLayerUIConfiguration:(LYRUIConfiguration *)layerUIConfiguration {
    NSAssert(conversation, @"Conversation cannot be nil");
    NSAssert(layerUIConfiguration, @"Layer UI Configuration cannot be nil");
    self = [super init];
    if (self) {
        _conversation = conversation;
        _layerUIConfiguration = layerUIConfiguration;
    }
    return self;
}

- (void)loadView {
    self.view = [[LYRUIIdentityListView alloc] initWithConfiguration:self.layerUIConfiguration];
}

- (LYRUIIdentityListView *)identityListView {
    if ([self.view isKindOfClass:[LYRUIIdentityListView class]]) {
        return (LYRUIIdentityListView *)self.view;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LYRMConversationDetailViewControllerTitle;
    
    LYRUIListSection *section = [[LYRUIListSection alloc] init];
    section.items = [self filteredParticipants];
    self.identityListView.items = [@[section] mutableCopy];
}

#pragma mark - Helpers

- (NSMutableArray *)filteredParticipants {
    NSMutableArray *participants = [[self.conversation.participants allObjects] mutableCopy];
    [participants removeObject:self.layerUIConfiguration.client.authenticatedUser];
    [participants sortUsingDescriptors:@[
            [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES],
    ]];
    return participants;
}

@end
