//
//  LYRMHTTPResponseSerializer.m
//  XDK Messenger
//
//  Created by Blake Watters on 6/28/14.
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

#import "LYRMHTTPResponseSerializer.h"

NSString *const LYRMHTTPResponseErrorDomain = @"com.layer.XDK-Messenger";
static NSRange const LYRMHTTPSuccessStatusCodeRange = {200, 100};
static NSRange const LYRMHTTPClientErrorStatusCodeRange = {400, 100};
static NSRange const LYRMHTTPServerErrorStatusCodeRange = {500, 100};

typedef NS_ENUM(NSInteger, LYRMHTTPResponseStatus) {
    LYRMHTTPResponseStatusSuccess,
    LYRMHTTPResponseStatusClientError,
    LYRMHTTPResponseStatusServerError,
    LYRMHTTPResponseStatusOther,
};

static LYRMHTTPResponseStatus LYRMHTTPResponseStatusFromStatusCode(NSInteger statusCode)
{
    if (NSLocationInRange(statusCode, LYRMHTTPSuccessStatusCodeRange)) return LYRMHTTPResponseStatusSuccess;
    if (NSLocationInRange(statusCode, LYRMHTTPClientErrorStatusCodeRange)) return LYRMHTTPResponseStatusClientError;
    if (NSLocationInRange(statusCode, LYRMHTTPServerErrorStatusCodeRange)) return LYRMHTTPResponseStatusServerError;
    return LYRMHTTPResponseStatusOther;
}

static NSString *LYRMHTTPErrorMessageFromErrorRepresentation(id representation)
{
    if ([representation isKindOfClass:[NSString class]]) {
        return representation;
    } else if ([representation isKindOfClass:[NSArray class]]) {
        return [representation componentsJoinedByString:@", "];
    } else if ([representation isKindOfClass:[NSDictionary class]]) {
        // Check for direct error message
        id errorMessage = representation[@"error"];
        if (errorMessage) {
            return LYRMHTTPErrorMessageFromErrorRepresentation(errorMessage);
        }
        
        // Rails errors in nested dictionary
        id errors = representation[@"errors"];
        if ([errors isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *messages = [NSMutableArray new];
            [errors enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString *description = LYRMHTTPErrorMessageFromErrorRepresentation(obj);
                NSString *message = [NSString stringWithFormat:@"%@ %@", key, description];
                [messages addObject:message];
            }];
            return [messages componentsJoinedByString:@" "];
        }
    }
    return [NSString stringWithFormat:@"An unknown error representation was encountered. (%@)", representation];
}

@implementation LYRMHTTPResponseSerializer

+ (BOOL)responseObject:(id *)object withData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError **)error
{
    NSParameterAssert(object);
    NSParameterAssert(response);
    
    if (data.length && ![response.MIMEType isEqualToString:@"application/json"]) {
        NSString *description = [NSString stringWithFormat:@"Expected content type of 'application/json', but encountered a response with '%@' instead.", response.MIMEType];
        if (error) *error = [NSError errorWithDomain:LYRMHTTPResponseErrorDomain code:LYRMHTTPResponseErrorInvalidContentType userInfo:@{NSLocalizedDescriptionKey: description}];
        return NO;
    }
    
    LYRMHTTPResponseStatus status = LYRMHTTPResponseStatusFromStatusCode(response.statusCode);
    if (status == LYRMHTTPResponseStatusOther) {
        NSString *description = [NSString stringWithFormat:@"Expected status code of 2xx, 4xx, or 5xx but encountered a status code '%ld' instead.", (long)response.statusCode];
        if (error) *error = [NSError errorWithDomain:LYRMHTTPResponseErrorDomain code:LYRMHTTPResponseErrorInvalidContentType userInfo:@{NSLocalizedDescriptionKey: description}];
        return NO;
    }
    
    // No response body
    if (!data.length) {
        if (status != LYRMHTTPResponseStatusSuccess) {
            if (error) {
                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"An error was encountered without a response body."};
                *error = [NSError errorWithDomain:LYRMHTTPResponseErrorDomain code:(status == LYRMHTTPResponseStatusClientError ? LYRMHTTPResponseErrorClientError : LYRMHTTPResponseErrorServerError) userInfo:userInfo];
            }
            return NO;
        } else {
            // Successful response with no data (typical of a 204 (No Content) response)
            *object = nil;
            return YES;
        }
    }
    
    // We have response body and passed Content-Type checks, deserialize it
    NSError *serializationError;
    id deserializedResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
    if (!deserializedResponse) {
        if (error) *error = serializationError;
        return NO;
    }
    
    if (status != LYRMHTTPResponseStatusSuccess) {
        NSString *errorMessage = LYRMHTTPErrorMessageFromErrorRepresentation(deserializedResponse);
        if (error) {
            NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: errorMessage, @"responseBody": responseBody };
            *error = [NSError errorWithDomain:LYRMHTTPResponseErrorDomain code:(status == LYRMHTTPResponseStatusClientError ? LYRMHTTPResponseErrorClientError : LYRMHTTPResponseErrorServerError) userInfo:userInfo];
        }
        return NO;
    }
    
    *object = deserializedResponse;
    return YES;
}

@end
