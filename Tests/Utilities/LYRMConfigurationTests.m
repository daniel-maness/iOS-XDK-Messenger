//
//  LYRMConfigurationTests.m
//  XDK Messenger
//
//  Created by JP McGlone on 2/3/17.
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LYRMConfiguration.h"
#import <Expecta/Expecta.h>

@interface LYRMConfigurationTests : XCTestCase

@end

/**
 @abstract Locates and returns the test configuration file used in this test case.
 @param suffix Appends a given string at the end of the filename with a dash ('-')
   in front of it.
 @return Returns a file `NSURL` instance pointing to the test configuration file.
 */
NSURL *LYRMConfigurationTestsDefaultConfigurationPath(NSString *__nullable suffix)
{
    NSBundle *bundle = [NSBundle bundleForClass:[LYRMConfigurationTests class]];
    NSURL *fileURL = [bundle URLForResource:suffix == nil ? @"TestLayerConfiguration": [@"TestLayerConfiguration-" stringByAppendingString:suffix] withExtension:@"json"];
    return fileURL;
}

@implementation LYRMConfigurationTests

- (void)testInitShouldFail
{
    // Call wrong initialization method
    expect(^{
        id allocatedConfig = [LYRMConfiguration alloc];
        __unused id noresult = [allocatedConfig init];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to call designated initializer. Call the designated initializer 'initWithFileURL:' on the `LYRMConfiguration` instead.");
}

- (void)testInitPassingNilShouldFail
{
    // Pass in `nil` as fileURL.
    expect(^{
        __unused id nullVal = nil;
        __unused id noresult = [[LYRMConfiguration alloc] initWithFileURL:nullVal];
    }).to.raiseWithReason(NSInvalidArgumentException, @"Failed to initialize `LYRMConfiguration` because the `fileURL` argument was `nil`.");
}

- (void)testInitPassingInvalidPathShouldFail
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[LYRMConfiguration alloc] initWithFileURL:[NSURL URLWithString:@"/dev/null"]];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `LYRMConfiguration` because the input file could not be read; error=Error Domain=NSCocoaErrorDomain Code=256 \"The file “null” couldn’t be opened.\" UserInfo={NSURL=/dev/null}");
}

- (void)testInitPassingInvalidJSONShouldFail
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[LYRMConfiguration alloc] initWithFileURL:LYRMConfigurationTestsDefaultConfigurationPath(@"invalid")];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `LYRMConfiguration` because the input file could not be deserialized; error=Error Domain=NSCocoaErrorDomain Code=3840 \"Something looked like a 'null' but wasn't around character 0.\" UserInfo={NSDebugDescription=Something looked like a 'null' but wasn't around character 0.}");
}

- (void)testInitFailingDueToAppIDMissing
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[LYRMConfiguration alloc] initWithFileURL:LYRMConfigurationTestsDefaultConfigurationPath(@"appIDNotSet")];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `LYRMConfiguration` because `app_id` key in the input file was not set.");
}

- (void)testInitFailingDueToNullAppID
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[LYRMConfiguration alloc] initWithFileURL:LYRMConfigurationTestsDefaultConfigurationPath(@"appIDNull")];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `LYRMConfiguration` because `app_id` key value in the input file was `null`.");
}

- (void)testInitFailingDueToInvalidAppID
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[LYRMConfiguration alloc] initWithFileURL:LYRMConfigurationTestsDefaultConfigurationPath(@"appIDInvalid")];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `LYRMConfiguration` because `app_id` key value in the input file was not a valid URL. appID=' '");
}

- (void)testInitFailingDueToIdentityProviderURLMissing
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[LYRMConfiguration alloc] initWithFileURL:LYRMConfigurationTestsDefaultConfigurationPath(@"identityProviderURLNotSet")];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `LYRMConfiguration` because `identity_provider_url` key in the input file was not set.");
}

- (void)testInitFailingDueToNullIdentityProviderURL
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[LYRMConfiguration alloc] initWithFileURL:LYRMConfigurationTestsDefaultConfigurationPath(@"identityProviderURLNull")];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `LYRMConfiguration` because `identity_provider_url` key value in the input file was `null`.");
}

- (void)testInitFailingDueToInvalidIdentityProviderURL
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[LYRMConfiguration alloc] initWithFileURL:LYRMConfigurationTestsDefaultConfigurationPath(@"identityProviderURLInvalid")];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `LYRMConfiguration` because `identity_provider_url` key value in the input file was not a valid URL. identityProviderURL=' '");
}

- (void)testInitFailingDueToJSONNotAnArray
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[LYRMConfiguration alloc] initWithFileURL:LYRMConfigurationTestsDefaultConfigurationPath(@"notArray")];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `LYRMConfiguration` because the input file JSON root was not an array");
}

- (void)testInitFailingDueToNameNotString
{
    // Pass a non-readable path as fileURL.
    expect(^{
        __unused id noresult = [[LYRMConfiguration alloc] initWithFileURL:LYRMConfigurationTestsDefaultConfigurationPath(@"nameNotString")];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to initialize `LYRMConfiguration` because `name` key in the input file was not an NSString.");
}

- (void)testInitSuccessfullyDeserializesValidConfigurationFile
{
    LYRMConfiguration *configuration = [[LYRMConfiguration alloc] initWithFileURL:LYRMConfigurationTestsDefaultConfigurationPath(nil)];
    expect(configuration.appID.absoluteString).to.equal(@"layer:///apps/staging/test");
    expect(configuration.identityProviderURL.absoluteString).to.equal(@"https://test.herokuapp.com/authenticate");
    expect(configuration.name).to.equal(@"TestApp");
}

- (void)testInitSuccessfullyDeserializesValidConfigurationFileWithCustomIdentityProvider
{
    LYRMConfiguration *configuration = [[LYRMConfiguration alloc] initWithFileURL:LYRMConfigurationTestsDefaultConfigurationPath(@"customIdentityProvider")];
    expect(configuration.appID.absoluteString).to.equal(@"layer:///apps/staging/test");
    expect(configuration.identityProviderURL.absoluteString).to.equal(@"https://test.herokuapp.com/users/sign_in.json");
    expect(configuration.name).to.equal(@"TestApp");
}

@end
