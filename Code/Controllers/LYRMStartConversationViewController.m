//
//  LYRMStartConversationViewController.m
//  XDK Messenger
//
//  Created by Łukasz Przytuła on 02.02.2018.
//  Copyright © 2018 Layer, Inc. All rights reserved.
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


#import "LYRMStartConversationViewController.h"
#import <LayerXDK/LayerXDKUI.h>
#import <LayerXDK/LYRUIStatusMessage.h>
#import <LayerKit/LayerKit.h>

@interface LYRMStartConversationViewController ()

@property (nonatomic) LYRUIConfiguration *layerUIConfiguration;

@end

@implementation LYRMStartConversationViewController

- (id)initWithLayerUIConfiguration:(LYRUIConfiguration *)layerUIConfiguration {
    NSAssert(layerUIConfiguration, @"Layer UI Configuration cannot be nil");
    self = [super init];
    if (self) {
        _layerUIConfiguration = layerUIConfiguration;
    }
    return self;
}

- (void)loadView {
    self.view = [[LYRUIIdentityListView alloc] initWithConfiguration:self.layerUIConfiguration];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(donePressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Start conversation"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(startConversationPressed:)];
    
    self.identityListView.collectionView.allowsMultipleSelection = YES;
    [self setupIdentitiesQueryController];
}

- (void)setupIdentitiesQueryController {
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRIdentity class]];
    query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:NO]];
    query.predicate = [LYRPredicate predicateWithProperty:@"userID"
                                        predicateOperator:LYRPredicateOperatorIsNotEqualTo
                                                    value:self.layerUIConfiguration.client.authenticatedUser.userID];
    
    
    NSError *error;
    LYRQueryController *queryController = [self.layerUIConfiguration.client queryControllerWithQuery:query error:&error];
    if (!queryController) {
        NSLog(@"LayerKit failed to create a query controller with error: %@", error);
        return;
    }
    
    self.identityListView.queryController = queryController;
    
    BOOL success = [queryController execute:&error];
    if (!success) {
        NSLog(@"LayerKit failed to execute query with error: %@", error);
    }
}

#pragma mark - Actions

- (IBAction)donePressed:(id)sender {
    [self.delegate startConversationViewControllerDidDismiss:self];
}

- (IBAction)startConversationPressed:(id)sender {
    if (self.identityListView.selectedItems.count == 0) {
        return;
    }
    LYRConversation *conversation = [self createConversationWithParticipants:self.identityListView.selectedItems];
    if (conversation == nil) {
        return;
    }
    [self.delegate startConversationViewController:self didCreateConversation:conversation];
}

#pragma mark - Helpers

- (LYRUIIdentityListView *)identityListView {
    if ([self.view isKindOfClass:[LYRUIIdentityListView class]]) {
        return (LYRUIIdentityListView *)self.view;
    }
    return nil;
}

- (LYRConversation *)createConversationWithParticipants:(NSArray<LYRIdentity *> *)participants {
    NSSet *participantIdentifiers = [NSSet setWithArray:[participants valueForKey:@"userID"]];
    LYRConversation *conversation = [self existingConversationForParticipants:participantIdentifiers];
    if (!conversation) {
        conversation = [self.layerUIConfiguration.client newConversationWithParticipants:participantIdentifiers options:nil error:nil];
        LYRUIMessageSender *messageSender = [[LYRUIMessageSender alloc] initWithConfiguration:self.layerUIConfiguration];
        messageSender.conversation = conversation;
        NSString *userName = self.layerUIConfiguration.client.authenticatedUser.displayName;
        LYRUIStatusMessage *statusMessage = [[LYRUIStatusMessage alloc] initWithText:[NSString stringWithFormat:@"%@ started conversation", userName]];
        [messageSender sendMessage:statusMessage];
    }
    return conversation;
}

- (LYRConversation *)existingConversationForParticipants:(NSSet *)participants {
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"participants" predicateOperator:LYRPredicateOperatorIsEqualTo value:participants];
    query.limit = 1;
    return [self.layerUIConfiguration.client executeQuery:query error:nil].firstObject;
}

@end
