//
//  LYRMErrors.h
//  XDK Messenger
//
//  Created by Kevin Coleman on 9/26/14.
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

extern NSString *const LYRMErrorDomain;

typedef NS_ENUM(NSUInteger, LYRMAuthenticationError) {
    LYRMErrorUnknownError                            = 7000,
    
    /* Messaging Errors */
    LYRMInvalidFirstName                              = 7001,
    LYRMInvalidLastName                               = 7002,
    LYRMInvalidEmailAddress                           = 7003,
    LYRMInvalidPassword                               = 7004,
    LYRMInvalidAuthenticationNonce                    = 7005,
    LYRMNoAuthenticatedSession                        = 7006,
    LYRMRequestInProgress                             = 7007,
    LYRMInvalidAppIDString                            = 7008,
    LYRMInvalidAppID                                  = 7009,
    LYRMInvalidIdentityToken                          = 7010,
    LYRMDeviceTypeNotSupported                        = 7011,
    LYRMAuthenticationErrorNoDataTransmitted          = 7012
};
