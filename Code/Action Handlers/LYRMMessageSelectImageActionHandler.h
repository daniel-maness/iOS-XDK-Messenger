//
//  LYRMMessageSelectImageActionHandler.h
//  XDK Messenger
//
//  Created by Daniel Maness on 6/26/18.
//  Copyright © 2018 Layer, Inc. All rights reserved.
//

#import "LYRUIActionHandling.h"

@interface LYRMMessageSelectImageActionHandler : NSObject <LYRUIActionHandling>

- (void)handleActionWithData:(id)data delegate:(id<LYRUIActionHandlingDelegate>)delegate;

@end
