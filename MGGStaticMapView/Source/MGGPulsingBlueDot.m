//
//  MGGPulsingBlueDot.m
//  MGGStaticMapView
//
//  Created by Mason Glidden on 3/14/15.
//  Copyright (c) 2015 mgg. All rights reserved.
//

#import "MGGPulsingBlueDot.h"

static const CGFloat kOuterDotDimension = 22.0;

static const CGFloat kInnerBlueDotRelativeMinSize = 0.58;
static const CGFloat kInnerBlueDotRelativeMaxSize = 0.72;
static const CGFloat kInnerBlueDotScaleFactor = kInnerBlueDotRelativeMaxSize / kInnerBlueDotRelativeMinSize;

@interface MGGPulsingBlueDot ()
@property (strong, nonatomic) UIView *outerBlueDot;
@property (strong, nonatomic) UIView *middleWhiteDot;
@property (strong, nonatomic) UIView *innerBlueDot;
@end

@implementation MGGPulsingBlueDot

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _middleWhiteDot = [[UIView alloc] init];
    _middleWhiteDot.backgroundColor = [UIColor whiteColor];
    _middleWhiteDot.layer.cornerRadius = kOuterDotDimension / 2.0;
    _middleWhiteDot.layer.shadowColor = [UIColor blackColor].CGColor;
    _middleWhiteDot.layer.shadowRadius = 10.0;
    _middleWhiteDot.layer.shadowOpacity = 0.2;
    
    _innerBlueDot = [[UIView alloc] init];
    _innerBlueDot.backgroundColor = [[self class] _smallColor];
    _innerBlueDot.translatesAutoresizingMaskIntoConstraints = NO;
    _innerBlueDot.layer.cornerRadius = kOuterDotDimension * kInnerBlueDotRelativeMinSize / 2.0;
    [self addSubview:_innerBlueDot];
    
    [self _installConstraints];
    [self _startAnimation];
  }
  return self;
}

- (void)_installConstraints {
  [self addConstraints:@[
                         [NSLayoutConstraint constraintWithItem:self.innerBlueDot attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:kOuterDotDimension*kInnerBlueDotRelativeMinSize],
                         [NSLayoutConstraint constraintWithItem:self.innerBlueDot attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.innerBlueDot attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0],
                         [NSLayoutConstraint constraintWithItem:self.innerBlueDot attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],
                         [NSLayoutConstraint constraintWithItem:self.innerBlueDot attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0],
                         ]];
  
}

- (void)_startAnimation {
  [UIView animateKeyframesWithDuration:1.5 delay:0.0 options:UIViewKeyframeAnimationOptionRepeat|UIViewKeyframeAnimationOptionAutoreverse animations:^{
    [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.925 animations:^{
      self.innerBlueDot.layer.transform = CATransform3DScale(CATransform3DIdentity, kInnerBlueDotScaleFactor, kInnerBlueDotScaleFactor, 1.0);
      self.innerBlueDot.backgroundColor = [[self class] _largeColor];
    }];
  } completion:nil];
}

- (CGSize)intrinsicContentSize {
  return CGSizeMake(kOuterDotDimension, kOuterDotDimension);
}

+ (UIColor *)_smallColor {
  return [UIColor colorWithRed:51.0/255.0 green:148.0/255.0 blue:255.0/255.0 alpha:1.0];
}

+ (UIColor *)_largeColor {
  return [UIColor colorWithRed:6.0/255.0 green:124.0/255.0 blue:255.0/255.0 alpha:1.0];
}

@end
