//
//  LYRMConversationListViewController.m
//  XDK Messenger
//
//  Created by Kevin Coleman on 8/29/14.
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

#import "LYRMConversationListViewController.h"
#import "LYRMConversationViewController.h"
#import "LYRMSettingsViewController.h"
#import <LayerXDK/LayerXDKUI.h>

@interface LYRMConversationListViewController () <LYRMSettingsViewControllerDelegate, UIActionSheetDelegate>

@property (nonatomic) LYRUIConfiguration *layerUIConfiguration;
@property (nonatomic, strong) LYRQueryController *queryController;
@property (nonatomic, readonly) LYRClient *layerClient;

@end

@implementation LYRMConversationListViewController

NSString *const LYRMConversationListTableViewAccessibilityLabel = @"Conversation List Table View";
NSString *const LYRMSettingsButtonAccessibilityLabel = @"Settings Button";
NSString *const LYRMComposeButtonAccessibilityLabel = @"Compose Button";

+ (instancetype)conversationListViewControllerWithLayerUIConfiguration:(LYRUIConfiguration *)layerUIConfiguration {
    NSAssert(layerUIConfiguration, @"Layer UI Configuration cannot be nil");
    return [[self alloc] initWithLayerUIConfiguration:layerUIConfiguration];
}

- (instancetype)initWithLayerUIConfiguration:(LYRUIConfiguration *)layerUIConfiguration {
    NSAssert(layerUIConfiguration, @"Layer UI Configuration cannot be nil");
    self = [super init];
    if (self)  {
        _layerUIConfiguration = layerUIConfiguration;
    }
    return self;
}

#pragma mark UIView overrides

- (void)loadView {
    self.view = [[LYRUIConversationListView alloc] initWithConfiguration:self.layerUIConfiguration];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak __typeof(self) weakSelf = self;
    self.conversationListView.itemSelected = ^(LYRConversation *conversation) {
        [weakSelf presentControllerWithConversation:conversation];
    };
    
    // Left navigation item
    UIButton* infoButton= [UIButton buttonWithType:UIButtonTypeInfoLight];
    UIBarButtonItem *infoItem  = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [infoButton addTarget:self action:@selector(settingsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    infoButton.accessibilityLabel = LYRMSettingsButtonAccessibilityLabel;
    [self.navigationItem setLeftBarButtonItem:infoItem];
    
    // Right navigation item
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeButtonTapped)];
    composeButton.accessibilityLabel = LYRMComposeButtonAccessibilityLabel;
    [self.navigationItem setRightBarButtonItem:composeButton];
    
    [self registerNotificationObservers];
    
    self.definesPresentationContext = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.queryController == nil) {
        [self setupConversationQueryController];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupConversationQueryController {
    NSAssert(self.queryController == nil, @"Cannot initialize more than once");
    if (!self.layerClient.authenticatedUser) {
        return;
    }
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastMessage.receivedAt" ascending:NO]];
    
    NSError *error;
    self.queryController = [self.layerUIConfiguration.client queryControllerWithQuery:query error:&error];
    if (!self.queryController) {
        NSLog(@"LayerKit failed to create a query controller with error: %@", error);
        return;
    }
    
    self.conversationListView.queryController = self.queryController;
    
    BOOL success = [self.queryController execute:&error];
    if (!success) {
        NSLog(@"LayerKit failed to execute query with error: %@", error);
    }
}

#pragma mark - Conversation Selection

// The following method handles presenting the correct `LYRMConversationViewController`, regardeless of the current state of the navigation stack.
- (void)presentControllerWithConversation:(LYRConversation *)conversation {
    LYRMConversationViewController *existingConversationViewController = [self existingConversationViewController];
    if (existingConversationViewController && existingConversationViewController.conversation == conversation) {
        if (self.navigationController.topViewController == existingConversationViewController) {
            return;
        }
        [self.navigationController popToViewController:existingConversationViewController animated:YES];
        return;
    }
    LYRMConversationViewController *conversationViewController = [LYRMConversationViewController conversationViewControllerWithConversation:conversation
                                                                                                                   withLayerUIConfiguration:self.layerUIConfiguration];
    [self.navigationController pushViewController:conversationViewController animated:YES];
}

#pragma mark - Actions

- (void)settingsButtonTapped {
    LYRMSettingsViewController *settingsViewController = [[LYRMSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    settingsViewController.layerUIConfiguration = self.layerUIConfiguration;
    settingsViewController.settingsDelegate = self;
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

- (void)composeButtonTapped {
    [self presentControllerWithConversation:nil];
}

#pragma mark - Conversation Selection From Push Notification

- (void)selectConversation:(LYRConversation *)conversation {
    if (conversation) {
        [self presentControllerWithConversation:conversation];
    }
}

#pragma mark - LYRMSettingsViewControllerDelegate

- (void)switchUserTappedInSettingsViewController:(LYRMSettingsViewController *)settingsViewController {
    // Nothing to do. 
}

- (void)logoutTappedInSettingsViewController:(LYRMSettingsViewController *)settingsViewController {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    if (self.layerClient.isConnected) {
        if ([weakSelf.presentationDelegate respondsToSelector:@selector(conversationListViewControllerWillBeDismissed:)]) {
            [weakSelf.presentationDelegate conversationListViewControllerWillBeDismissed:weakSelf];
        }
        
        [self.layerClient.authenticatedUser removeObserver:settingsViewController forKeyPath:@"presenceStatus"];
        [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
            [SVProgressHUD dismiss];
            [settingsViewController dismissViewControllerAnimated:YES completion:^{
                // Inform the presentation delegate all subviews (from child view
                // controllers) have been dismissed.
                if ([weakSelf.presentationDelegate respondsToSelector:@selector(conversationListViewControllerWasDismissed:)]) {
                    [weakSelf.presentationDelegate conversationListViewControllerWasDismissed:weakSelf];
                }
            }];
        }];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Unable to logout. Layer is not connected"];
    }
}

- (void)settingsViewControllerDidFinish:(LYRMSettingsViewController *)settingsViewController {
    [settingsViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notification Handlers

- (void)conversationDeleted:(NSNotification *)notification {
    LYRMConversationViewController *conversationViewController = [self existingConversationViewController];
    if (!conversationViewController) return;
    
    LYRConversation *deletedConversation = notification.object;
    if (![conversationViewController.conversation isEqual:deletedConversation]) return;
    conversationViewController = nil;
    [self.navigationController popToViewController:self animated:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Conversation Deleted"
                                                        message:@"The conversation has been deleted."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)conversationParticipantsDidChange:(NSNotification *)notification {
    NSString *authenticatedUserID = self.layerClient.authenticatedUser.userID;
    if (!authenticatedUserID) return;
    LYRConversation *conversation = notification.object;
    if ([[conversation.participants valueForKeyPath:@"userID"] containsObject:authenticatedUserID]) return;
    
    LYRMConversationViewController *conversationViewController = [self existingConversationViewController];
    if (!conversationViewController) return;
    if (![conversationViewController.conversation isEqual:conversation]) return;
    
    [self.navigationController popToViewController:self animated:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Removed From Conversation"
                                                        message:@"You have been removed from the conversation."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Helpers

- (LYRUIConversationListView *)conversationListView {
    if ([self.view isKindOfClass:[LYRUIConversationListView class]]) {
        return (LYRUIConversationListView *)self.view;
    }
    return nil;
}

- (LYRClient *)layerClient {
    return self.layerUIConfiguration.client;
}

- (LYRMConversationViewController *)existingConversationViewController {
    if (!self.navigationController) return nil;
    
    NSUInteger listViewControllerIndex = [self.navigationController.viewControllers indexOfObject:self];
    if (listViewControllerIndex == NSNotFound) return nil;
    
    NSUInteger nextViewControllerIndex = listViewControllerIndex + 1;
    if (nextViewControllerIndex >= self.navigationController.viewControllers.count) return nil;
    
    id nextViewController = [self.navigationController.viewControllers objectAtIndex:nextViewControllerIndex];
    if (![nextViewController isKindOfClass:[LYRMConversationViewController class]]) return nil;
    
    return nextViewController;
}

- (void)registerNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationDeleted:) name:LYRMConversationDeletedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationParticipantsDidChange:) name:LYRMConversationParticipantsDidChangeNotification object:nil];
}

@end
