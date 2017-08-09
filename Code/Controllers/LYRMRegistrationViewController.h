//
//  LSRegistrationViewController.h
//  QRCodeTest
//
//  Created by Kevin Coleman on 2/15/15.
//  Copyright (c) 2015 Layer. All rights reserved.
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
#import "LYRMLayerController.h"

@class LYRMUserCredentials;
@class LYRMRegistrationViewController;

/**
 @abstract The `LYRMQRScannerControllerDelegate` notifies the receiver when
   the scanner view controller detects a Layer App ID, or in case there was
   a problem during detection.
 */
@protocol LYRMRegistrationViewControllerDelegate <NSObject>

/**
 @abstract
 @param registrationViewController The sender that did the delegate invocation.
 @param credentials The Layer appID the scanner detected.
 */
- (void)registrationViewController:(nonnull LYRMRegistrationViewController *)registrationViewController didSubmitCredentials:(nonnull LYRMUserCredentials *)credentials;

@end

/**
 @abstract The `LYRMRegistrationViewController` presents a simple interface for registering a user with a user name.
 */
@interface LYRMRegistrationViewController : UIViewController

/**
 @abstract The receiver of the appID, once the QC code scanner recognizes it.
 */
@property (nullable, nonatomic, weak) id<LYRMRegistrationViewControllerDelegate> delegate;

@end
