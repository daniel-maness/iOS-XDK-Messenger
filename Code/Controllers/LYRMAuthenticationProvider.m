//
//  LYRMAuthenticationProvider.m
//  XDK Messenger
//
//  Created by Kevin Coleman on 5/26/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
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


#import "LYRMAuthenticationProvider.h"
#import "LYRMHTTPResponseSerializer.h"
#import "LYRMConstants.h"
#import "LYRMConfiguration.h"
#import "LYRMUtilities.h"
#import "LYRMErrors.h"

NSString *const LYRMEmailKey = @"LYRMEmailKey";
NSString *const LYRMPasswordKey = @"LYRMPasswordKey";
NSString *const LYRMCredentialsKey = @"LYRMCredentialsKey";
static NSString *const LYRMXDKIdentityTokenKey = @"identity_token";

NSString *const LYRMListUsersEndpoint = @"/users.json";

@interface LYRMAuthenticationProvider ();

@property (nonatomic) NSURL *baseURL;
@property (nonatomic) NSURLSession *URLSession;

@end

@implementation LYRMAuthenticationProvider

+ (nonnull instancetype)providerWithBaseURL:(nonnull NSURL *)baseURL layerAppID:(NSURL *)layerAppID
{
    return  [[self alloc] initWithBaseURL:baseURL layerAppID:layerAppID];
}

- (instancetype)initWithConfiguration:(LYRMConfiguration *)configuration
{
    NSURL *appIDURL = configuration.appID;
    NSURL *identityProviderURL = (configuration.identityProviderURL ?: LYRMRailsBaseURL(LYRMEnvironmentProduction));
    
    self = [self initWithBaseURL:identityProviderURL layerAppID:appIDURL];
    return self;
}

- (instancetype)initWithBaseURL:(nonnull NSURL *)baseURL layerAppID:(NSURL *)layerAppID;
{
    if (baseURL == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Cannot initialize %@ with `baseURL` argument being nil", self.class];
    }
    if (layerAppID == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Cannot initialize %@ with `layerAppID` argument being nil", self.class];
    }
    
    self = [super init];
    if (self) {
        _baseURL = baseURL;
        _layerAppID = layerAppID;
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        // X_LAYER_APP_ID is for Legacy Identity Provider
        configuration.HTTPAdditionalHeaders = @{ @"Accept": @"application/json",
                                                 @"X_LAYER_APP_ID": self.layerAppID.absoluteString.lastPathComponent };
        _URLSession = [NSURLSession sessionWithConfiguration:configuration];
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Failed to call designated initializer. Call the designated initializer on the subclass instead."
                                 userInfo:nil];
}

- (void)authenticateWithCredentials:(NSDictionary *)credentials nonce:(NSString *)nonce completion:(void (^)(NSString *identityToken, NSError *error))completion
{
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:credentials];
    [payload setObject:nonce forKey:@"nonce"];
    
    // This is to support Legacy Identity Provider protocol
    [payload setObject:credentials forKey:@"user"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.baseURL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }
        
        if (!data) {
            NSError *error = [NSError errorWithDomain:LYRMErrorDomain code:LYRMAuthenticationErrorNoDataTransmitted userInfo:@{NSLocalizedDescriptionKey: @"Expected identity information in the response from the server, but none was received."}];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setValue:credentials forKey:LYRMCredentialsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // TODO: Basic response and content checks — status and length
        NSError *serializationError;
        NSDictionary *rawResponse = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
        if (serializationError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, serializationError);
            });
            return;
        }
        
        // Legacy identity provider uses layer_identity_token
        NSString *identityToken = rawResponse[@"identity_token"] ?: rawResponse[@"layer_identity_token"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!identityToken) {
                NSError *error = [NSError errorWithDomain:LYRMErrorDomain code:LYRMInvalidIdentityToken userInfo:@{NSLocalizedDescriptionKey: @"Authentication failed because the Identity token was nil."}];
                completion(nil, error);
            } else {
                completion(identityToken, nil);
            }
        });
    }] resume];
}

- (void)refreshAuthenticationWithNonce:(NSString *)nonce completion:(void (^)(NSString *identityToken, NSError *error))completion
{
    NSDictionary *credentials = [[NSUserDefaults standardUserDefaults] objectForKey:LYRMCredentialsKey];
    [self authenticateWithCredentials:credentials nonce:nonce completion:^(NSString * _Nonnull identityToken, NSError * _Nonnull error) {
        completion(identityToken, error);
    }];
}

@end
