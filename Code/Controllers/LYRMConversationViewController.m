//
//  LYRMConversationViewController.m
//  XDK Messenger
//
//  Created by Kevin Coleman on 9/10/14.
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

#import "LYRMConversationViewController.h"
#import "LYRMConversationDetailViewController.h"
#import "LYRMUtilities.h"
#import "LYRMParticipantTableViewController.h"
#import "LYRMLayerController.h"
#import "LYRMStartConversationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <LayerKit/LayerKit.h>
#import <LayerXDK/LayerXDKUI.h>

@interface LYRMConversationViewController () <CLLocationManagerDelegate, UIActionSheetDelegate,
                                              UINavigationControllerDelegate, UIImagePickerControllerDelegate,
                                              LYRMStartConversationViewControllerDelegate>

@property (nonatomic) LYRUIConfiguration *layerUIConfiguration;
@property (nonatomic, readwrite) LYRConversation *conversation;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL shouldShareLocation;

@property (nonatomic) BOOL shouldScrollToLastMessage;
@property (nonatomic) dispatch_once_t onceToken;

@end

@implementation LYRMConversationViewController

NSString *const LYRMConversationViewControllerAccessibilityLabel = @"Conversation View Controller";
NSString *const LYRMDetailsButtonAccessibilityLabel = @"Details Button";
NSString *const LYRMDetailsButtonLabel = @"Details";

+ (instancetype)conversationViewControllerWithConversation:(LYRConversation *)conversation withLayerUIConfiguration:(LYRUIConfiguration *)layerUIConfiguration {
    return [[self alloc] initWithConversation:conversation withLayerUIConfiguration:layerUIConfiguration];
}

- (instancetype)initWithConversation:(LYRConversation *)conversation withLayerUIConfiguration:(LYRUIConfiguration *)layerUIConfiguration {
    NSAssert(layerUIConfiguration, @"Layer UI Configuration cannot be nil");
    self = [self init];
    if (self)  {
        _conversation = conversation;
        _layerUIConfiguration = layerUIConfiguration;
        self.shouldScrollToLastMessage = YES;
    }
    return self;
}

- (void)loadView {
    self.view = [[LYRUIConversationView alloc] initWithConfiguration:self.layerUIConfiguration];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.accessibilityLabel = LYRMConversationViewControllerAccessibilityLabel;
    
    [self.conversationView.messageListView registerViewControllerForPreviewing:self];
   
    if (self.conversation) {
        self.conversationView.conversation = self.conversation;
        [self configureTitle];
        [self addDetailsButton];
    }
    [self addPhotoAttachmentButton];
    [self addLocationButton];
    [self registerNotificationObservers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureTitle];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.conversation == nil) {
        dispatch_once(&_onceToken, ^{
            LYRMStartConversationViewController *startConversationViewController = [[LYRMStartConversationViewController alloc] initWithLayerUIConfiguration:self.layerUIConfiguration];
            startConversationViewController.delegate = self;
            UINavigationController *navigationViewController = [[UINavigationController alloc] initWithRootViewController:startConversationViewController];
            [self presentViewController:navigationViewController animated:YES completion:nil];
        });
    }
    
    if (self.shouldScrollToLastMessage) {
        [self.conversationView.messageListView scrollToLastMessageAnimated:YES];
        self.shouldScrollToLastMessage = NO;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.shouldScrollToLastMessage) {
        [self.conversationView.messageListView scrollToLastMessageAnimated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (![self isMovingFromParentViewController]) {
        [self.view resignFirstResponder];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Attachments

- (void)addPhotoAttachmentButton {
    UIButton *photoButton = [[UIButton alloc] init];
    photoButton.contentMode = UIViewContentModeScaleAspectFit;
    [photoButton setImage:[UIImage imageNamed:@"camera_dark"] forState:UIControlStateNormal];
    [photoButton addTarget:self action:@selector(sendPhotoAttachment) forControlEvents:UIControlEventTouchUpInside];
    [self setupButtonSizeConstraints:photoButton];
    
    self.conversationView.composeBar.leftItems = @[photoButton];
}

- (void)sendPhotoAttachment {
    if (self.conversationView.composeBar.inputTextView.isFirstResponder) {
        [self.conversationView.composeBar.inputTextView resignFirstResponder];
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take Photo", @"Photo Library", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - Location Message

- (void)addLocationButton {
    UIButton *locationButton = [[UIButton alloc] init];
    locationButton.contentMode = UIViewContentModeScaleAspectFit;
    [locationButton setImage:[UIImage imageNamed:@"location_dark"] forState:UIControlStateNormal];
    [locationButton addTarget:self action:@selector(sendLocationMessage) forControlEvents:UIControlEventTouchUpInside];
    [self setupButtonSizeConstraints:locationButton];
    
    UIButton *sendButton = self.conversationView.composeBar.sendButton;
    self.conversationView.composeBar.rightItems = @[locationButton, sendButton];
}

- (void)sendLocationMessage {
    self.shouldShareLocation = YES;
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    if ([self.locationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (!self.shouldShareLocation) return;
    if (locations.firstObject) {
        self.shouldShareLocation = NO;
        [self.conversationView.messageListView.messageSender sendMessageWithLocation:locations.firstObject];
        [self.locationManager stopUpdatingLocation];
    }
}

#pragma mark - Details Button Actions

- (void)addDetailsButton {
    if (self.navigationItem.rightBarButtonItem) return;

    UIBarButtonItem *detailsButtonItem = [[UIBarButtonItem alloc] initWithTitle:LYRMDetailsButtonLabel
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(detailsButtonTapped)];
    detailsButtonItem.accessibilityLabel = LYRMDetailsButtonAccessibilityLabel;
    self.navigationItem.rightBarButtonItem = detailsButtonItem;
}

- (void)detailsButtonTapped {
    LYRMConversationDetailViewController *detailViewController = [LYRMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation withLayerUIConfiguration:self.layerUIConfiguration];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - Notification Handlers

- (void)conversationMetadataDidChange:(NSNotification *)notification {
    if (!self.conversation) return;
    if (!notification.object) return;
    if (![notification.object isEqual:self.conversation]) return;

    [self configureTitle];
}

#pragma mark - Helpers

- (LYRUIConversationView *)conversationView {
    if ([self.view isKindOfClass:[LYRUIConversationView class]]) {
        return (LYRUIConversationView *)self.view;
    }
    return nil;
}

- (LYRClient *)layerClient {
    return self.layerUIConfiguration.client;
}

- (void)setupButtonSizeConstraints:(UIButton *)button {
    [button sizeToFit];
    [button.widthAnchor constraintEqualToConstant:CGRectGetWidth(button.frame)].active = YES;
    [button.heightAnchor constraintEqualToConstant:CGRectGetHeight(button.frame)].active = YES;
    button.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)configureTitle {
    if ([self.conversation.metadata valueForKey:LYRMConversationMetadataNameKey]) {
        NSString *conversationTitle = [self.conversation.metadata valueForKey:LYRMConversationMetadataNameKey];
        if (conversationTitle.length) {
            self.title = conversationTitle;
        } else {
            self.title = [self defaultTitle];
        }    } else {
        self.title = [self defaultTitle];
    }
}

- (NSString *)defaultTitle {
    if (!self.conversation) {
        return @"New Message";
    }
    
    NSMutableSet *otherParticipants = [self.conversation.participants mutableCopy];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID != %@", self.layerClient.authenticatedUser.userID];
    [otherParticipants filterUsingPredicate:predicate];
    
    if (otherParticipants.count == 0) {
        return @"Personal";
    } else if (otherParticipants.count == 1) {
        LYRIdentity *otherIdentity = [otherParticipants anyObject];
        return otherIdentity ? otherIdentity.firstName : @"Message";
    } else if (otherParticipants.count > 1) {
        NSUInteger participantCount = 0;
        LYRIdentity *knownParticipant;
        for (LYRIdentity *identity in otherParticipants) {
            if (identity) {
                participantCount += 1;
                knownParticipant = identity;
            }
        }
        if (participantCount == 1) {
            return knownParticipant.firstName;
        } else if (participantCount > 1) {
            return @"Group";
        }
    }
    return @"Message";
}

#pragma mark - Link Tap Handler

- (void)registerNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationMetadataDidChange:) name:LYRMConversationMetadataDidChangeNotification object:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self displayImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
            break;
            
        case 1:
            [self displayImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
            
        default:
            break;
    }
}

#pragma mark - Image Picking

- (void)displayImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    BOOL pickerSourceTypeAvailable = [UIImagePickerController isSourceTypeAvailable:sourceType];
    if (pickerSourceTypeAvailable) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = sourceType;
        picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
        [self.navigationController presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (info[UIImagePickerControllerOriginalImage]) {
        // Image picked from the image picker.
        [self.conversationView.messageListView.messageSender sendMessageWithImage:info[UIImagePickerControllerOriginalImage]];
    } else {
        return;
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.view becomeFirstResponder];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.view becomeFirstResponder];
}

#pragma mark - LYRMStartConversationViewControllerDelegate

- (void)startConversationViewControllerDidDismiss:(LYRMStartConversationViewController *)startConversationViewController {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)startConversationViewController:(LYRMStartConversationViewController *)startConversationViewController
                  didCreateConversation:(LYRConversation *)conversation {
    if (conversation == nil) {
        return;
    }
    
    self.conversation = conversation;
    self.conversationView.conversation = self.conversation;
    [self.conversationView.messageListView scrollToLastMessageAnimated:NO];
    [self configureTitle];
    [self addDetailsButton];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
