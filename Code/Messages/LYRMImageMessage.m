//
//  LYRMImageMessage.m
//  XDK Messenger
//
//  Created by Daniel Maness on 6/26/18.
//  Copyright © 2018 Layer, Inc. All rights reserved.
//

#import "LYRMImageMessage.h"

@implementation LYRMImageMessage

- (instancetype)initWithImage:(nullable UIImage *)image
                         previewImage:(nullable UIImage *)previewImage
                               action:(nullable LYRUIMessageAction *)action
{
    NSData *sourceImageData = UIImageJPEGRepresentation(image, 1.0);
    NSData *previewImageData = UIImageJPEGRepresentation(previewImage, 1.0);
    self = [self initWithArtist:nil
                          title:nil
                       subtitle:nil
                       fileName:nil
                  imageMIMEType:@"image/jpeg"
                           size:image.size
                    previewSize:previewImage.size
                      createdAt:nil
                    orientation:0
                previewImageURL:nil
           previewImageLocalURL:nil
               previewImageData:previewImageData
                 sourceImageURL:nil
            sourceImageLocalURL:nil
                sourceImageData:sourceImageData
                         action:action
                         sender:nil
                         sentAt:nil
                         status:nil];
    return self;
}

+ (NSString *)MIMEType {
    return @"application/vnd.layer.custom.image+json";
}

@end
