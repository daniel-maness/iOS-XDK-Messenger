//
//  LYRMUserCredentials.m
//  XDK Messenger
//
//  Created by Daniel Maness on 11/10/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import "LYRMUserCredentials.h"

static NSString *defaultsEmailKey = @"DEFAULTS_EMAIL";
static NSString *defaultsPasswordKey = @"DEFAULTS_PASSWORD";
// https://xkcd.com/221/

@implementation LYRMUserCredentials

- (instancetype)initWithEmail:(NSString *)email password:(NSString *)password
{
    self = [super init];
    self.email = email;
    self.password = password;
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Failed to call designated initializer. Call the designated initializer on the subclass instead."
                                 userInfo:nil];
}

- (NSDictionary *)asDictionary {
    return @{@"email": self.email, @"password": self.password};
}
@end
