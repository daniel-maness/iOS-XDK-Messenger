//
//  LYRMConversationDetailViewController.h
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

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@class LYRUIConfiguration;
@class LYRConversation;

extern NSString *const LYRMConversationDetailViewControllerTitle;
extern NSString *const LYRMConversationMetadataNameKey;

@class LYRMConversationDetailViewController;

/**
 @abstract The `LYRMConversationDetailViewController` presents a user interface that displays information about a given
 conversation. It also provides for adding/removing participants to/from a conversation and sharing the user's location.
 */
@interface LYRMConversationDetailViewController : UIViewController

///--------------------------------
/// @name Initializing a Controller
///--------------------------------

+ (instancetype)conversationDetailViewControllerWithConversation:(LYRConversation *)conversation withLayerUIConfiguration:(LYRUIConfiguration *)layerUIConfiguration;

@end
