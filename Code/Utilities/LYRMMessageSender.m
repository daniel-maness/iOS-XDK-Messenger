//
//  LYRMMessageSender.m
//  XDK Messenger
//
//  Created by Daniel Maness on 6/26/18.
//  Copyright © 2018 Layer, Inc. All rights reserved.
//

#import "LYRMMessageSender.h"
#import "LYRMImageMessage.h"
#import "LYRUIMessageSerializer.h"
#import "UIImage+LYRUIThumbnail.h"

@interface LYRMMessageSender ()

@property (nonatomic, strong) LYRUIMessageSerializer *messageSerializer;

@end

@implementation LYRMMessageSender

- (void)sendMessageWithImage:(UIImage *)image {
    if (self.conversation == nil || self.layerConfiguration.client == nil) {
        return;
    }

    NSMutableDictionary *eventData = [[NSMutableDictionary alloc] init];
    [eventData setValue:self.layerConfiguration.client.authenticatedUser.displayName forKey:@"photographer"];
    
    LYRUIMessageAction *action = [[LYRUIMessageAction alloc] initWithEvent:@"select-image" data:eventData];
    LYRMImageMessage *imageMessage = [[LYRMImageMessage alloc] initWithImage:image previewImage:image.lyr_thumbnail action:action];
    
    LYRMessage *message = [self.messageSerializer layerMessageWithTypedMessage:imageMessage];
    [self sendLayerMessage:message];
}

- (void)sendLayerMessage:(LYRMessage *)message {
    NSError *error;
    BOOL success = [self.conversation sendMessage:message error:&error];
    if (!success) {
        NSLog(@"Failed to send image message with error: %@", error);
    }
}

@end
