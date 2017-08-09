//
//  LYRMSettingsViewController.h
//  XDK Messenger
//
//  Created by Kevin Coleman on 10/20/14.
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

#import <UIKit/UIKit.h>
@class LYRUIConfiguration;

@class LYRMSettingsViewController;

extern NSString * _Nonnull const LYRMSettingsViewControllerTitle;
extern NSString * _Nonnull const LYRMSettingsTableViewAccessibilityIdentifier;
extern NSString * _Nonnull const LYRMSettingsHeaderAccessibilityLabel;

extern NSString * _Nonnull const LYRMDefaultCellIdentifier;
extern NSString * _Nonnull const LYRMCenterTextCellIdentifier;

extern NSString * _Nonnull const LYRMConnected;
extern NSString * _Nonnull const LYRMDisconnected;
extern NSString * _Nonnull const LYRMLostConnection;
extern NSString * _Nonnull const LYRMConnecting;

/**
 @abstract The `LYRMSettingsViewControllerDelegate` protocol informs the receiver of events that have occurred within the controller.
 */
@protocol LYRMSettingsViewControllerDelegate <NSObject>

/**
 @abstract Informs the receiver that a logout button has been tapped in the controller.
 @param settingsViewController The controller in which the selection occurred.
 */
- (void)logoutTappedInSettingsViewController:(nonnull LYRMSettingsViewController *)settingsViewController;

/**
 @abstract Informs the receiver that a switch user button has been tapped in the controller.
 @param settingsViewController The controller in which the selection occurred.
 */
- (void)switchUserTappedInSettingsViewController:(nonnull LYRMSettingsViewController *)settingsViewController;

/**
 @abstract Informs the receiver that the user wants to dismiss the controller.
 @param settingsViewController The controller in which the selection occurred.
 */
- (void)settingsViewControllerDidFinish:(nonnull LYRMSettingsViewController *)settingsViewController;

@end

/**
 @abstract The `LYRMSettingsViewController` presents a user interface for viewing and configuring application settings in addition to viewing information related to the application.
 */
@interface LYRMSettingsViewController : UITableViewController

- (nullable instancetype)initWithStyle:(UITableViewStyle)style;
- (nullable instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil;
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder;

/**
 @abstract The configuration object for the UI components.
 */
@property (nonnull, nonatomic) LYRUIConfiguration *layerUIConfiguration;

/**
 @abstract The `LYRMSettingsViewControllerDelegate` object for the controller.
 */
@property (nullable, nonatomic, weak) id<LYRMSettingsViewControllerDelegate> settingsDelegate;

@end
