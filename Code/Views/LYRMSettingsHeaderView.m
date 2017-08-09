//
//  LYRMSettingsHeaderView.m
//  XDK Messenger
//
//  Created by Kevin Coleman on 10/23/14.
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

#import "LYRMSettingsHeaderView.h"
#import <LayerXDK/LayerXDKUI.h>

@interface LYRMSettingsHeaderView ()

@property (nonatomic) LYRIdentity *user;
@property (nonatomic) LYRUIAvatarView *avatarView;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *connectionStateLabel;
@property (nonatomic) UILabel *authenticationStateLabel;
@property (nonatomic) UIView *bottomBorder;

@end

@implementation LYRMSettingsHeaderView

static CGFloat const LYRMAvatarDiameter = 72;

+ (instancetype)headerViewWithUser:(LYRIdentity *)user
{
    return [[self alloc] initHeaderViewWithUser:user];
}

- (id)initHeaderViewWithUser:(LYRIdentity *)user
{
    self = [super init];
    if (self) {
        _user = user;
        self.backgroundColor = [UIColor whiteColor];

        _avatarView = [[LYRUIAvatarView alloc] init];
        _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
        _avatarView.identities = @[user];
        [self addSubview:_avatarView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.text = user.displayName;
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = UIColor.lightGrayColor;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_nameLabel];
        
        _connectionStateLabel = [[UILabel alloc] init];
        _connectionStateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _connectionStateLabel.font = [UIFont systemFontOfSize:14];
        _connectionStateLabel.textColor = UIColor.blueColor;
        _connectionStateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_connectionStateLabel];
        
        _authenticationStateLabel = [[UILabel alloc] init];
        _authenticationStateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _authenticationStateLabel.font = [UIFont systemFontOfSize:14];
        _authenticationStateLabel.textColor = UIColor.blueColor;
        _authenticationStateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_authenticationStateLabel];
    
        _bottomBorder = [[UIView alloc] init];
        _bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomBorder.backgroundColor = UIColor.lightGrayColor;
        [self addSubview:_bottomBorder];

        [self configureAvatarViewConstraints];
        [self configureNameLabelConstraints];
        [self configureConnectionLabelConstraints];
        [self configureAuthenticationLabelConstraints];
        [self configureBottomBorderConstraints];
    }
    return self;
}

- (void)configureAvatarViewConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:LYRMAvatarDiameter]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:LYRMAvatarDiameter]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:20]];
}

- (void)configureNameLabelConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:4]];
}

- (void)configureConnectionLabelConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.connectionStateLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.connectionStateLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:20]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.connectionStateLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.connectionStateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
}

- (void)configureAuthenticationLabelConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.authenticationStateLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.authenticationStateLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:20]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.authenticationStateLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.authenticationStateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.connectionStateLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
}

- (void)configureBottomBorderConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorder  attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorder attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorder attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.authenticationStateLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorder attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
}

- (void)updateConnectedStateWithString:(NSString *)string
{
    self.connectionStateLabel.text = string;
}

- (void)updateAuthenticatedStateWithString:(NSString *)string
{
    self.authenticationStateLabel.text = string;
}

- (void)setNeedsDisplay
{
//    self.avatarView.avatarItem = (id<ATLAvatarItem>)self.user;
    [super setNeedsDisplay];
}

- (void)setLayerUIConfiguration:(LYRUIConfiguration *)layerUIConfiguration {
    _layerUIConfiguration = layerUIConfiguration;
    self.avatarView.layerConfiguration = layerUIConfiguration;
    self.avatarView.identities = @[layerUIConfiguration.client.authenticatedUser];
}

@end
