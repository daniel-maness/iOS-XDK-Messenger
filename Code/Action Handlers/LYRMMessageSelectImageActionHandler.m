//
//  LYRMMessageSelectImageActionHandler.m
//  XDK Messenger
//
//  Created by Daniel Maness on 6/26/18.
//  Copyright © 2018 Layer, Inc. All rights reserved.
//

#import "LYRMMessageSelectImageActionHandler.h"

@implementation LYRMMessageSelectImageActionHandler

- (void)handleActionWithData:(id)data delegate:(id<LYRUIActionHandlingDelegate>)delegate
{
    NSLog(@"Image photographed by %@", data[@"photographer"]);
}

- (UIViewController *)viewControllerForActionWithData:(id)data
{
    if (data == nil || data[@"url"] == nil) {
        return nil;
    }
    
    UIViewController *viewController = [[UIViewController alloc] init];
    return viewController;
}

@end
