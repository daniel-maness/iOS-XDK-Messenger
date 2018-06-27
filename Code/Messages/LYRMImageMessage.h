//
//  LYRMImageMessage.h
//  XDK Messenger
//
//  Created by Daniel Maness on 6/26/18.
//  Copyright © 2018 Layer, Inc. All rights reserved.
//

#import "LYRUIImageMessage.h"

@interface LYRMImageMessage : LYRUIImageMessage

- (nonnull instancetype)initWithImage:(nullable UIImage *)image
                         previewImage:(nullable UIImage *)previewImage
                               action:(nullable LYRUIMessageAction *)action;

@end
