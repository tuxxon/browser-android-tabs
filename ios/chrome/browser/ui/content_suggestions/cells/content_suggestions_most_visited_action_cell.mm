// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/ui/content_suggestions/cells/content_suggestions_most_visited_action_cell.h"

#import "ios/chrome/browser/ui/content_suggestions/cells/content_suggestions_most_visited_constants.h"
#include "ios/chrome/browser/ui/ui_util.h"
#import "ios/chrome/browser/ui/uikit_ui_util.h"
#import "ios/chrome/common/favicon/favicon_view.h"
#import "ios/chrome/common/material_timing.h"
#import "ios/chrome/common/ui_util/constraints_ui_util.h"
#import "ios/third_party/material_components_ios/src/components/Typography/src/MaterialTypography.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

namespace {

const CGFloat kCountWidth = 20;
const CGFloat kCountBorderWidth = 24;

const int kBackgroundColor = 0xE8F1FC;

}  // namespace

@implementation ContentSuggestionsMostVisitedActionCell : MDCCollectionViewCell

@synthesize countContainer = _countContainer;
@synthesize countLabel = _countLabel;
@synthesize iconView = _iconView;
@synthesize titleLabel = _titleLabel;

#pragma mark - Public

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor colorWithWhite:0 alpha:kTitleAlpha];
    _titleLabel.font = [UIFont systemFontOfSize:12];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.preferredMaxLayoutWidth = [[self class] defaultSize].width;
    _titleLabel.numberOfLines = kLabelNumLines;

    _iconView = [[UIImageView alloc] initWithFrame:self.bounds];

    UIImageView* iconBackground = [[UIImageView alloc] init];
    iconBackground.image = [[UIImage imageNamed:@"ntp_most_visited_tile"]
        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    iconBackground.tintColor = UIColorFromRGB(kBackgroundColor);

    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _iconView.translatesAutoresizingMaskIntoConstraints = NO;
    iconBackground.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:iconBackground];
    [self.contentView addSubview:_titleLabel];
    [self.contentView addSubview:_iconView];

    [NSLayoutConstraint activateConstraints:@[
      [_iconView.widthAnchor constraintEqualToConstant:kIconSize],
      [iconBackground.widthAnchor
          constraintEqualToAnchor:_iconView.widthAnchor],
      [_iconView.heightAnchor constraintEqualToAnchor:_iconView.widthAnchor],
      [iconBackground.heightAnchor
          constraintEqualToAnchor:iconBackground.widthAnchor],
      [_iconView.centerXAnchor
          constraintEqualToAnchor:_titleLabel.centerXAnchor],
    ]];

    AddSameCenterXConstraint(iconBackground, _iconView);
    AddSameCenterYConstraint(iconBackground, _iconView);

    ApplyVisualConstraintsWithMetrics(
        @[ @"V:|[icon]-(space)-[title]", @"H:|[title]|" ],
        @{@"icon" : _iconView, @"title" : _titleLabel},
        @{ @"space" : @(kSpaceIconTitle) });

    self.isAccessibilityElement = YES;
  }
  return self;
}

- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];

  [UIView transitionWithView:self
                    duration:ios::material::kDuration8
                     options:UIViewAnimationOptionCurveEaseInOut
                  animations:^{
                    self.alpha = highlighted ? 0.5 : 1.0;
                  }
                  completion:nil];
}

+ (CGSize)defaultSize {
  return kCellSize;
}

- (CGSize)intrinsicContentSize {
  return [[self class] defaultSize];
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _countContainer.hidden = YES;
}

- (UILabel*)countLabel {
  if (!_countLabel) {
    _countContainer = [[UIView alloc] init];
    _countContainer.backgroundColor = [UIColor whiteColor];
    // Unfortunately, simply setting a CALayer borderWidth and borderColor
    // on |_countContainer|, and setting a background color on |_countLabel|
    // will result in the inner color bleeeding thru to the outside.
    _countContainer.layer.cornerRadius = kCountBorderWidth / 2;
    _countContainer.layer.masksToBounds = YES;

    _countLabel = [[UILabel alloc] init];
    _countLabel.layer.cornerRadius = kCountWidth / 2;
    _countLabel.layer.masksToBounds = YES;
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.font = [MDCTypography captionFont];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.backgroundColor =
        [UIColor colorWithRed:0.10 green:0.45 blue:0.91 alpha:1.0];

    _countContainer.translatesAutoresizingMaskIntoConstraints = NO;
    _countLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:self.countContainer];
    [self.countContainer addSubview:self.countLabel];

    [NSLayoutConstraint activateConstraints:@[
      [_countContainer.widthAnchor constraintEqualToConstant:kCountBorderWidth],
      [_countContainer.heightAnchor
          constraintEqualToAnchor:_countContainer.widthAnchor],
      [_countContainer.topAnchor
          constraintEqualToAnchor:self.contentView.topAnchor],
      [_countContainer.trailingAnchor
          constraintEqualToAnchor:self.contentView.trailingAnchor],
      [_countLabel.widthAnchor constraintEqualToConstant:kCountWidth],
      [_countLabel.heightAnchor
          constraintEqualToAnchor:_countLabel.widthAnchor],
    ]];
    AddSameCenterConstraints(_countLabel, _countContainer);
  }
  _countContainer.hidden = NO;
  return _countLabel;
}

@end
