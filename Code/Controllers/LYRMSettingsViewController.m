//
//  LYRMSettingsViewController.m
//  XDK Messenger
//
//  Created by Kevin Coleman on 10/20/14.
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

#import "LYRMSettingsViewController.h"
#import <LayerXDK/LayerXDKUI.h>
#import <LayerKitDiagnostics/LayerKitDiagnostics.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "LYRMSettingsHeaderView.h"
#import "LYRMLogoView.h"
#import "LYRMUtilities.h"
#import <LayerXDK/LYRUIConfiguration.h>
#import "LYRMStyleValue1TableViewCell.h"
#import "LYRMCenterTextTableViewCell.h"

typedef NS_ENUM(NSInteger, LYRMSettingsTableSection) {
    LYRMSettingsTableSectionPresenceStatus,
    LYRMSettingsTableSectionSupport,
    LYRMSettingsTableSectionInfo,
    LYRMSettingsTableSectionLegal,
    LYRMSettingsTableSectionLogout,
    LYRMSettingsTableSectionCount
};

typedef NS_ENUM(NSInteger, LYRMPresenceStatusTableRow) {
    LYRMPresenceStatusTableRowPicker,
    LYRMPresenceStatusTableRowCount,
};

typedef NS_ENUM(NSInteger, LYRMInfoTableRow) {
    LYRMInfoTableRowMessengerVersion,
    LYRMInfoTableRowXDKVersion,
    LYRMInfoTableRowLayerKitVersion,
    LYRMInfoTableRowAppIDRow,
    LYRMInfoTableRowCount,
};

typedef NS_ENUM(NSInteger, LYRMLegalTableRow) {
    LYRMLegalTableRowAttribution,
    LYRMLegalTableRowTerms,
    LYRMLegalTableRowCount,
};


@interface LYRMSettingsViewController () <UITextFieldDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic) LYRMSettingsHeaderView *headerView;
@property (nonatomic) LYRMLogoView *logoView;
@property (nonatomic, readonly) LYRClient *layerClient;

@end

@implementation LYRMSettingsViewController

NSString *const LYRMSettingsViewControllerTitle = @"Settings";
NSString *const LYRMSettingsTableViewAccessibilityIdentifier = @"Settings Table View";
NSString *const LYRMSettingsHeaderAccessibilityLabel = @"Settings Header";

NSString *const LYRMDefaultCellIdentifier = @"defaultTableViewCell";
NSString *const LYRMCenterTextCellIdentifier = @"centerContentTableViewCell";

NSString *const LYRMConnected = @"Connected";
NSString *const LYRMDisconnected = @"Disconnected";
NSString *const LYRMLostConnection = @"Lost Connection";
NSString *const LYRMConnecting = @"Connecting";
NSString *const LYRMAuthenticated = @"Authenticated";
NSString *const LYRMUnauthenticated = @"Unauthenticated";
NSString *const LYRMChallenged = @"Challenged";

NSString *const LYRMPresenceStatusKey = @"presenceStatus";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = LYRMSettingsViewControllerTitle;
    
    [self.tableView registerClass:[LYRMStyleValue1TableViewCell class] forCellReuseIdentifier:LYRMDefaultCellIdentifier];
    [self.tableView registerClass:[LYRMCenterTextTableViewCell class] forCellReuseIdentifier:LYRMCenterTextCellIdentifier];
    
    self.headerView = [LYRMSettingsHeaderView headerViewWithUser:self.layerUIConfiguration.client.authenticatedUser];
    self.headerView.layerUIConfiguration = self.layerUIConfiguration;
    self.headerView.frame = CGRectMake(0, 0, 320, 156);
    self.headerView.accessibilityLabel = LYRMSettingsHeaderAccessibilityLabel;
    
    if (self.layerClient.isConnected) {
        [self.headerView updateConnectedStateWithString:LYRMConnected];
    } else {
        [self.headerView updateConnectedStateWithString:LYRMDisconnected];
    }
    
    if (self.layerClient.currentSession.state == LYRSessionStateAuthenticated) {
        [self.headerView updateAuthenticatedStateWithString:LYRMAuthenticated];
    } else if (self.layerClient.currentSession.state == LYRSessionStateUnauthenticated) {
        [self.headerView updateAuthenticatedStateWithString:LYRMUnauthenticated];
    } else if (self.layerClient.currentSession.state == LYRSessionStateChallenged) {
        [self.headerView updateAuthenticatedStateWithString:LYRMChallenged];
    }
    
    self.logoView = [[LYRMLogoView alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
    self.tableView.tableFooterView = self.logoView;
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.sectionHeaderHeight = 48.0f;
    self.tableView.rowHeight = 44.0f;
    self.tableView.accessibilityIdentifier = LYRMSettingsTableViewAccessibilityIdentifier;
    
    [self registerNotificationObservers];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.layerClient.authenticatedUser removeObserver:self forKeyPath:LYRMPresenceStatusKey];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return LYRMSettingsTableSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case LYRMSettingsTableSectionSupport:
            return 1;
        
        case LYRMSettingsTableSectionInfo:
            return LYRMInfoTableRowCount;
            
        case LYRMSettingsTableSectionPresenceStatus:
            return LYRMPresenceStatusTableRowCount;
            
        case LYRMSettingsTableSectionLegal:
            return LYRMLegalTableRowCount;
            
        case LYRMSettingsTableSectionLogout:
            return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case LYRMSettingsTableSectionSupport: {
            LYRMCenterTextTableViewCell *centerCell = [self.tableView dequeueReusableCellWithIdentifier:LYRMCenterTextCellIdentifier forIndexPath:indexPath];
            centerCell.centerTextLabel.text = @"Send Layer Diagnostics";
            centerCell.centerTextLabel.textColor = UIColor.redColor;
            return centerCell;
        }
        
        case LYRMSettingsTableSectionInfo: {
            UITableViewCell *cell = [self defaultCellForIndexPath:indexPath];
            switch (indexPath.row) {
                case LYRMInfoTableRowMessengerVersion: {
                    cell.textLabel.text = @"Messenger Version";
                    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
                    NSString *version = [infoDict objectForKey:@"CFBundleShortVersionString"];
                    cell.detailTextLabel.text = version;
                    break;
                }
                case LYRMInfoTableRowXDKVersion:
                    cell.textLabel.text = @"Layer XDK UI Version";
                    cell.detailTextLabel.text = LYRUIVersionString;
                    break;
                    
                case LYRMInfoTableRowLayerKitVersion:
                    cell.textLabel.text = @"LayerKit Version";
                    cell.detailTextLabel.text = LYRSDKVersionString;
                    break;
                    
                case LYRMInfoTableRowAppIDRow:
                    cell.textLabel.text = @"App ID";
                    cell.detailTextLabel.text = [self.layerClient.appID absoluteString];
                    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
                    break;
                    
                case LYRMInfoTableRowCount:
                    break;
            }
            return cell;
        }
           
        case LYRMSettingsTableSectionPresenceStatus: {
            UITableViewCell *cell = [self defaultCellForIndexPath:indexPath];
            switch (indexPath.row) {
                case LYRMPresenceStatusTableRowPicker:
                {
                    cell.textLabel.text = @"Presence Status";
                    cell.detailTextLabel.text = LYRMStringForPresenceStatus(self.layerClient.authenticatedUser.presenceStatus);
                    break;
                }
                    
                case LYRMPresenceStatusTableRowCount:
                    break;
            }
            return cell;
        }
           
        case LYRMSettingsTableSectionLegal: {
            UITableViewCell *cell = [self defaultCellForIndexPath:indexPath];
            switch (indexPath.row) {
                case LYRMLegalTableRowAttribution:
                    cell.textLabel.text = @"Attribution";
                    break;
            
                case LYRMLegalTableRowTerms:
                    cell.textLabel.text = @"Terms Of Service";
                    break;
            
                case LYRMLegalTableRowCount:
                    break;
            }
            return cell;
        }
            
        case LYRMSettingsTableSectionLogout: {
            LYRMCenterTextTableViewCell *centerCell = [self.tableView dequeueReusableCellWithIdentifier:LYRMCenterTextCellIdentifier forIndexPath:indexPath];
            centerCell.centerTextLabel.text = @"Log Out";
            centerCell.centerTextLabel.textColor = UIColor.redColor;
            return centerCell;
        }

        case LYRMSettingsTableSectionCount:
            break;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case LYRMSettingsTableSectionSupport:
            return @"Support";
        
        case LYRMSettingsTableSectionInfo:
            return @"Info";

        case LYRMSettingsTableSectionLegal:
            return @"Legal";

        case LYRMSettingsTableSectionLogout:
        case LYRMSettingsTableSectionCount:
        case LYRMSettingsTableSectionPresenceStatus:
            return nil;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == LYRMSettingsTableSectionCount) {
        //TODO - Add XDK Footer
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - Cell Configuration

- (UITableViewCell *)defaultCellForIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LYRMDefaultCellIdentifier forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = nil;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case LYRMSettingsTableSectionSupport:
            [self sendLayerDiagnostics];
            break;
        case LYRMPresenceStatusTableRowPicker:
            [self presentPresencePicker];
            break;
        case LYRMSettingsTableSectionLogout:
            [self logOut];
            break;
        case LYRMSettingsTableSectionLegal:
            [self legalRowTapped:indexPath.row];
            break;
        default:
            break;
    }
}

#pragma mark - Actions

- (void)updatePresenceStatus:(LYRIdentityPresenceStatus)presenceStatus
{
    [self.layerClient setPresenceStatus:presenceStatus error:nil];
    [self reloadPresenceStatus];
}

- (void)reloadPresenceStatus
{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:LYRMPresenceStatusTableRowPicker inSection:LYRMSettingsTableSectionPresenceStatus]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.headerView setNeedsDisplay];
}

- (UIAlertAction *)actionForPresenceStatus:(LYRIdentityPresenceStatus)presenceStatus
{
    __weak LYRMSettingsViewController *weakSelf = self;
    UIAlertAction *action = [UIAlertAction actionWithTitle:LYRMStringForPresenceStatus(presenceStatus) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf updatePresenceStatus:presenceStatus];
    }];
    
    if (presenceStatus == self.layerClient.authenticatedUser.presenceStatus) {
        UIImage *checkmark = [UIImage imageNamed:@"checkmark"];
        UIImage *scaledCheckmark = [UIImage imageWithCGImage:[checkmark CGImage] scale:(checkmark.scale * 3) orientation:checkmark.imageOrientation];
        [action setValue:scaledCheckmark forKey:@"_image"];
    }
    
    return action;
}

- (void)presentPresencePicker
{
    UIAlertController *alertController = [[UIAlertController alloc] init];
    
    // Presence Statuses
    [alertController addAction:[self actionForPresenceStatus:LYRIdentityPresenceStatusAvailable]];
    [alertController addAction:[self actionForPresenceStatus:LYRIdentityPresenceStatusBusy]];
    [alertController addAction:[self actionForPresenceStatus:LYRIdentityPresenceStatusAway]];
    [alertController addAction:[self actionForPresenceStatus:LYRIdentityPresenceStatusInvisible]];
    
    // Cnacel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)sendLayerDiagnostics
{
    // Include recipients to be Cced on this email
    NSArray *recipients = [NSArray arrayWithObjects:@"", nil];
    LYRDEmailDiagnosticsViewController *diagnosticsViewController = [[LYRDEmailDiagnosticsViewController alloc] initWithLayerClient:self.layerClient withCcRecipients:recipients];
    diagnosticsViewController.mailComposeDelegate = self;
    [diagnosticsViewController captureDiagnosticsWithCompletion:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            while (topViewController.presentedViewController) {
                topViewController = topViewController.presentedViewController;
            }
            
            [topViewController presentViewController:diagnosticsViewController animated:YES completion:nil];
        } else {
            NSLog(@"Diagnostics email could not be sent: %@", error);
        }
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:NO completion:nil];
}

- (void)logOut
{
    if (self.layerClient.isConnected) {
        [self.settingsDelegate logoutTappedInSettingsViewController:self];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Cannot Logout. Layer is not connected"];
    }
    
}

- (void)legalRowTapped:(LYRMLegalTableRow)tableRow
{
    switch (tableRow) {
        case LYRMLegalTableRowAttribution:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/layerhq/iOS-XDK-Messenger#license"]];
            break;
        case LYRMLegalTableRowTerms:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://layer.com/terms"]];
            break;
        default:
            break;
    }
}

# pragma mark - Layer Connection State Monitoring

- (void)registerNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerDidConnect:) name:LYRClientDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerDidDisconnect:) name:LYRClientDidDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerIsConnecting:) name:LYRClientWillAttemptToConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerDidLoseConnection:) name:LYRClientDidLoseConnectionNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerDidAuthenticateUser:) name:LYRClientDidAuthenticateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerDidDeauthenticateUser:) name:LYRClientDidDeauthenticateNotification object:nil];
    
    [self.layerClient.authenticatedUser addObserver:self forKeyPath:LYRMPresenceStatusKey options:(NSKeyValueObservingOptionNew) context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadPresenceStatus];
    });
}

- (void)layerDidConnect:(NSNotification *)notification
{
    [self.headerView updateConnectedStateWithString:LYRMConnected];
}

- (void)layerDidDisconnect:(NSNotification *)notification
{
    [self.headerView updateConnectedStateWithString:LYRMDisconnected];
}

- (void)layerIsConnecting:(NSNotification *)notification
{
    [self.headerView updateConnectedStateWithString:LYRMConnecting];
}

- (void)layerDidLoseConnection:(NSNotification *)notification
{
    [self.headerView updateConnectedStateWithString:LYRMLostConnection];
}

- (void)layerDidAuthenticateUser:(NSNotification *)notification
{
    [self.headerView updateAuthenticatedStateWithString:LYRMAuthenticated];
}

- (void)layerDidDeauthenticateUser:(NSNotification *)notification
{
    [self.headerView updateAuthenticatedStateWithString:LYRMUnauthenticated];
}

#pragma mark - Properties

- (LYRClient *)layerClient {
    return self.layerUIConfiguration.client;
}

@end
