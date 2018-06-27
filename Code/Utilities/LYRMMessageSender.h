//
//  LYRMMessageSender.h
//  XDK Messenger
//
//  Created by Daniel Maness on 6/26/18.
//  Copyright © 2018 Layer, Inc. All rights reserved.
//

#import "LYRUIMessageSender.h"

@interface LYRMMessageSender : LYRUIMessageSender <LYRUIConfigurable>

- (void)sendMessageWithImage:(UIImage *)image;

@end
