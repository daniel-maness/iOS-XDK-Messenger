//
//  LYRMApplicationViewController.m
//  XDK Messenger
//
//  Created by Klemen Verdnik on 6/26/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import "LYRMApplicationViewController.h"
#import "LYRMSplashView.h"
#import "LYRMRegistrationViewController.h"
#import "LYRMConversationListViewController.h"
#import "LYRMConversationViewController.h"
#import "LYRMUtilities.h"
#import "LYRMUserCredentials.h"
#import <LayerXDK/LayerXDKUI.h>

///-------------------------
/// @name Application States
///-------------------------

typedef NS_ENUM(NSUInteger, LYRMApplicationState) {
    /**
     @abstract A state where the app has not yet established a state.
     */
    LYRMApplicationStateIndeterminate,
    
    /**
     @abstract A state where the app has the appID, but no user credentials.
     */
    LYRMApplicationStateCredentialsRequired,
    
    /**
     @abstract A state where the app is fully authenticated.
     */
    LYRMApplicationStateAuthenticated
};

static NSString *const LYRMPushNotificationSoundName = @"layerbell.caf";
static void *LYRMApplicationViewControllerObservationContext = &LYRMApplicationViewControllerObservationContext;

@interface LYRMApplicationViewController () <LYRMRegistrationViewControllerDelegate, LYRMConversationListViewControllerPresentationDelegate>

@property (assign, nonatomic, readwrite) LYRMApplicationState state;
@property (nullable, nonatomic) LYRMSplashView *splashView;
@property (nullable, nonatomic) UINavigationController *registrationNavigationController;
@property (nullable, nonatomic) LYRMConversationListViewController *conversationListViewController;
@property (nonatomic, strong) LYRUIMessageSender *messageSender;

@end

@implementation LYRMApplicationViewController

- (nonnull id)init
{
    self = [super init];
    if (self) {
        _state = LYRMApplicationStateIndeterminate;
        [self addObserver:self forKeyPath:@"state" options:0 context:LYRMApplicationViewControllerObservationContext];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"state"];
}

- (LYRMApplicationState)determineInitialApplicationState
{
    if (self.layerController.layerClient.authenticatedUser == nil) {
        return LYRMApplicationStateCredentialsRequired;
    } else {
        return LYRMApplicationStateAuthenticated;
    }
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context
{
    if (context == LYRMApplicationViewControllerObservationContext) {
        if ([keyPath isEqualToString:@"state"]) {
            [self presentViewControllerForApplicationState];
        }
    }
}

#pragma mark - UIViewController Overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeSplashViewVisible:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    LYRMApplicationState state = [self determineInitialApplicationState];
    if (state != self.state) {
        self.state = state;
    }
}

#pragma mark - Splash View

- (void)makeSplashViewVisible:(BOOL)visible
{
    if (visible) {
        // Add LYRMSplashView to the self.view
        if (!self.splashView) {
            self.splashView = [[LYRMSplashView alloc] initWithFrame:self.view.bounds];
        }
        [self.view addSubview:self.splashView];
    } else {
        // Fade out self.splashView and remove it from the self.view subviews' stack.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                self.splashView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self.splashView removeFromSuperview];
                self.splashView = nil;
            }];
        });
    }
}

#pragma mark - UI view controller presenting

- (void)presentRegistrationNavigationController
{
    if (!self.registrationNavigationController) {
        self.registrationNavigationController = [[UINavigationController alloc] init];
        self.registrationNavigationController.navigationBarHidden = YES;
        if (!self.childViewControllers.count) {
            // Only if there's no child view controller being presented on top.
            [self presentViewController:self.registrationNavigationController animated:YES completion:nil];
        }
        self.conversationListViewController = nil;
    }
}

- (void)presentRegistrationViewController
{
    if (!self.registrationNavigationController) {
        [self presentRegistrationNavigationController];
    }
    LYRMRegistrationViewController *registrationViewController = [LYRMRegistrationViewController new];
    registrationViewController.delegate = self;
    [self.registrationNavigationController pushViewController:registrationViewController animated:YES];
}

- (void)presentConversationListViewController
{
    [self.registrationNavigationController dismissViewControllerAnimated:YES completion:nil];
    self.registrationNavigationController = nil;
    
    self.conversationListViewController = [LYRMConversationListViewController conversationListViewControllerWithLayerUIConfiguration:self.layerController.layerConfiguration];
    self.conversationListViewController.presentationDelegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.conversationListViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Managing UI view transitions

- (void)presentViewControllerForApplicationState
{
    [self makeSplashViewVisible:YES];
    switch (self.state) {
        case LYRMApplicationStateCredentialsRequired: {
            [self presentRegistrationViewController];
            break;
        }
        case LYRMApplicationStateAuthenticated: {
            [self presentConversationListViewController];
            break;
        }
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Unhandled LYRMApplicationState value=%lu", (unsigned long)self.state];
            break;
    }
}

#pragma mark - LYRMConversationListViewControllerPresentationDelegate implementation

- (void)conversationListViewControllerWillBeDismissed:(nonnull LYRMConversationListViewController *)conversationListViewController
{
    // Prepare the current view controller for dismissal of the
    [self makeSplashViewVisible:YES];
}

- (void)conversationListViewControllerWasDismissed:(nonnull LYRMConversationListViewController *)conversationListViewController
{
    [self presentViewController:self.registrationNavigationController animated:YES completion:nil];
}

#pragma mark - LYRMLayerControllerDelegate implementation

- (void)applicationController:(LYRMLayerController *)applicationController didFinishHandlingRemoteNotificationForConversation:(LYRConversation *)conversation message:(LYRMessage *)message responseText:(nullable NSString *)responseText
{
    if (responseText.length) {
        // Handle the inline message reply.
        if (!conversation) {
            NSLog(@"Failed to complete inline reply: unable to find Conversation referenced by remote notification.");
            return;
        }
        self.messageSender.conversation = conversation;
        [self.messageSender sendMessageWithAttributedString:[[NSAttributedString alloc] initWithString:responseText]];
        return;
    }
    
    // Navigate to the conversation, after the remote notification's been handled.
    BOOL userTappedRemoteNotification = [UIApplication sharedApplication].applicationState == UIApplicationStateInactive;
    if (userTappedRemoteNotification && conversation) {
        [self.conversationListViewController selectConversation:conversation];
    } else if (userTappedRemoteNotification) {
        [SVProgressHUD showWithStatus:@"Loading Conversation"];
    }
}

- (void)setLayerController:(LYRMLayerController *)layerController
{
    if (_layerController == layerController) {
        return;
    }
    
    _layerController = layerController;
    if (layerController) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLayerClientWillAttemptToConnectNotification:) name:LYRClientWillAttemptToConnectNotification object:layerController.layerClient];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLayerClientDidConnectNotification:) name:LYRClientDidConnectNotification object:layerController.layerClient];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLayerClientDidDisconnectNotification:) name:LYRClientDidDisconnectNotification object:layerController.layerClient];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLayerClientDidLoseConnectionNotification:) name:LYRClientDidLoseConnectionNotification object:layerController.layerClient];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLayerClientDidAuthenticateNotification:) name:LYRClientDidAuthenticateNotification object:layerController.layerClient];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLayerClientDidDeauthenticateNotification:) name:LYRClientDidDeauthenticateNotification object:layerController.layerClient];
        
        // Connect the client
        [layerController.layerClient connectWithCompletion:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"Connected to Layer");
            } else {
                NSLog(@"Failed connection to Layer: %@", error);
            }
        }];
        
        if (self.state == LYRMApplicationStateIndeterminate) {
            return;
        }
        
        LYRMApplicationState state = [self determineInitialApplicationState];
        if (state != self.state) {
            self.state = state;
        }
        
        self.messageSender = [[LYRUIMessageSender alloc] initWithConfiguration:layerController.layerConfiguration];
    }
}

- (void)handleLayerClientWillAttemptToConnectNotification:(NSNotification *)notification
{
    unsigned long attemptNumber = [notification.userInfo[@"attemptNumber"] unsignedLongValue];
    unsigned long attemptLimit = [notification.userInfo[@"attemptLimit"] unsignedLongValue];
    NSTimeInterval delayInterval = [notification.userInfo[@"delayInterval"] floatValue];
    // Show HUD with message
    if (attemptNumber == 1) {
        [SVProgressHUD showWithStatus:@"Connecting to Layer"];
    } else {
        [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Connecting to Layer in %lus (%lu of %lu)", (unsigned long)ceil(delayInterval), attemptNumber, attemptLimit]];
    }
}

- (void)handleLayerClientDidConnectNotification:(NSNotification *)notification
{
    // Show HUD with message
    [SVProgressHUD showSuccessWithStatus:@"Connected to Layer"];
}

- (void)handleLayerClientDidDisconnectNotification:(NSNotification *)notification
{
    // Show HUD with message
    [SVProgressHUD showWithStatus:@"Disconnected from Layer"];
}

- (void)handleLayerClientDidLoseConnectionNotification:(NSNotification *)notification
{
    // Show HUD with message
    [SVProgressHUD showErrorWithStatus:@"Lost connection from Layer"];
}

- (void)handleLayerClientDidAuthenticateNotification:(NSNotification *)notification
{
    self.state = LYRMApplicationStateAuthenticated;
}

- (void)handleLayerClientDidDeauthenticateNotification:(NSNotification *)notification
{
    self.state = LYRMApplicationStateCredentialsRequired;
}

#pragma mark - LYRMRegistrationViewControllerDelegate implementation

- (void)registrationViewController:(LYRMRegistrationViewController *)registrationViewController didSubmitCredentials:(LYRMUserCredentials *)credentials
{
    [SVProgressHUD showWithStatus:@"Authenticating with Layer"];
    [self.layerController authenticateWithCredentials:credentials completion:^(LYRSession *_Nonnull session, NSError *_Nullable error) {
        [SVProgressHUD dismiss];
        if (session) {
            self.state = LYRMApplicationStateAuthenticated;
        } else {
            NSLog(@"Failed to authenticate with credentials=%@. errors=%@", credentials, error);
            LYRMAlertWithError(error);
        }
    }];
}

@end
