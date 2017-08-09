//
//  LYRMLogoView.m
//  QRCodeTest
//
//  Created by Kevin Coleman on 2/15/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import "LYRMLogoView.h"
#import <LayerXDK/LayerXDKUI.h> 
#import "LYRMConstants.h"

@interface LYRMLogoView ()

@property (nonatomic) UILabel *XDKLabel;
@property (nonatomic) UILabel *poweredByLabel;
@property (nonatomic) UIImageView *logoImageView;

@end

@implementation LYRMLogoView

CGFloat const LYRMLogoSize = 18;
CGFloat const LYRMLogoLeftPadding = 4;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSMutableAttributedString *XDKString = [[NSMutableAttributedString alloc] initWithString:@"XDK MESSENGER"];
        [XDKString addAttribute:NSFontAttributeName value:LYRMUltraLightFont(26) range:NSMakeRange(0, XDKString.length)];
        [XDKString addAttribute:NSForegroundColorAttributeName value:UIColor.blueColor range:NSMakeRange(0, XDKString.length)];
        [XDKString addAttribute:NSKernAttributeName value:@(12.0) range:NSMakeRange(0, XDKString.length)];
        
        _XDKLabel = [[UILabel alloc] init];
        _XDKLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _XDKLabel.attributedText = XDKString;
        [_XDKLabel sizeToFit];
        [self addSubview:_XDKLabel];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Powered By "];
        [attributedString addAttribute:NSForegroundColorAttributeName value:UIColor.lightGrayColor range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:9 weight:UIFontWeightLight] range:NSMakeRange(0, attributedString.length)];
        
        _poweredByLabel = [[UILabel alloc] init];
        _poweredByLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _poweredByLabel.attributedText = attributedString;
        [_poweredByLabel sizeToFit];
        [self addSubview:_poweredByLabel];
        
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _logoImageView.image = [UIImage imageNamed:@"layer-logo-gray"];
        [self addSubview:_logoImageView];
        
        [self configureLayoutConstraints];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(320, 80);
}

- (void)configureLayoutConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_XDKLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_XDKLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    CGFloat poweredByLabelOffset = (LYRMLogoSize + LYRMLogoLeftPadding) / LYRMLogoLeftPadding;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_poweredByLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-poweredByLabelOffset]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_poweredByLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_XDKLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_logoImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_poweredByLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:LYRMLogoLeftPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_logoImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_poweredByLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

@end
