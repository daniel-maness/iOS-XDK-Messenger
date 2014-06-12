//
//  LSAppDelegate.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSAppDelegate.h"

@implementation LSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeSDKs];
    
    LSHomeViewController *controller = [[LSHomeViewController alloc] init];
    
    LSNavigationController *navController = [[LSNavigationController alloc] initWithRootViewController:controller];
    
    controller.delegate = navController;
    
    navController.layerController = self.layerController;
    
    [self.window setRootViewController:navController];
    [self.window makeKeyAndVisible];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark
#pragma mark SDK Initialization Classes
- (void)initializeSDKs
{
    [self setLayerController:[[LSLayerController alloc] init]];
    [self setParseController:[[LSParseController alloc] init]];
}

- (void)setLayerController:(LSLayerController *)layerController
{
    if (_layerController != layerController) {
        _layerController = layerController;
    }
    [_layerController initializeLayerClientWithCompletion:^(NSError *error) {
        if (!error) NSLog(@"Layer Client Started");
    }];
}

- (void)setParseController:(LSParseController *)parseController
{
    if (_parseController != parseController) {
        _parseController = parseController;
    }
}

#pragma mark
#pragma mark HomeViewControllerDelegate Methods
-(void)presentConversationViewController
{

}
@end
