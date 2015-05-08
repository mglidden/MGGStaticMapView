//
//  MGGPulsingBlueDot.m
//  MGGStaticMapView
//
//  Created by Mason Glidden on 3/14/15.
//  Copyright (c) 2015 mgg. All rights reserved.
//

#import "MGGPulsingBlueDot.h"

static const CGFloat kOuterDotDimension = 22.0;

static const CGFloat kInnerBlueDotRelativeMinSize = 0.59;
static const CGFloat kInnerBlueDotRelativeMaxSize = 0.72;
static const CGFloat kInnerBlueDotScaleFactor = kInnerBlueDotRelativeMaxSize / kInnerBlueDotRelativeMinSize;
static const CGFloat kInnerBlueDotDimension = kOuterDotDimension * kInnerBlueDotRelativeMinSize;
static const CGFloat kInnerBlueDotAnimationTime = 1.2;

static const CGFloat kOuterBlueDotInitialDimension = kOuterDotDimension;
static const CGFloat kOuterBlueDotScaleFactor = 5.5;
static const CGFloat kOuterBlueDotInitialAlpha = 0.5;

@interface MGGPulsingBlueDot ()
@property (strong, nonatomic) UIView *accuracyDot;
@property (strong, nonatomic) UIView *outerBlueDot;
@property (strong, nonatomic) UIView *middleWhiteDot;
@property (strong, nonatomic) UIView *innerBlueDot;
@end

@implementation MGGPulsingBlueDot

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.clipsToBounds = NO;
    
    _accuracyDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kOuterDotDimension, kOuterDotDimension)];
    _accuracyDot.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:148.0/255.0 blue:255.0/255.0 alpha:1.0];
    _accuracyDot.alpha = 0.2;
    _accuracyDot.layer.cornerRadius = _accuracyDot.frame.size.height / 2.0;
    [self addSubview:_accuracyDot];
    
    _outerBlueDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kOuterBlueDotInitialDimension, kOuterBlueDotInitialDimension)];
    _outerBlueDot.backgroundColor = _accuracyDot.backgroundColor;
    _outerBlueDot.alpha = kOuterBlueDotInitialAlpha;
    _outerBlueDot.layer.cornerRadius = _outerBlueDot.frame.size.height / 2.0;
    [self addSubview:_outerBlueDot];
    
    _middleWhiteDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kOuterDotDimension, kOuterDotDimension)];
    _middleWhiteDot.backgroundColor = [UIColor whiteColor];
    _middleWhiteDot.layer.cornerRadius = _middleWhiteDot.frame.size.height / 2.0;
    _middleWhiteDot.layer.shadowColor = [UIColor blackColor].CGColor;
    _middleWhiteDot.layer.shadowRadius = 10.0;
    _middleWhiteDot.layer.shadowOpacity = 0.2;
    [self addSubview:_middleWhiteDot];
    
    _innerBlueDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kInnerBlueDotDimension, kInnerBlueDotDimension)];
    _innerBlueDot.backgroundColor = [self _innerDotSmallColor];
    _innerBlueDot.layer.cornerRadius = _innerBlueDot.frame.size.height / 2.0;
    [self addSubview:_innerBlueDot];
    
    [self _startAnimation];
  }
  return self;
}

#pragma mark Public Setters

- (void)setErrored:(BOOL)errored {
  _errored = errored;
  self.outerBlueDot.hidden = errored;
}

- (void)setAccuracyCircleRadius:(CGFloat)accuracyCircleRadius {
  _accuracyCircleRadius = accuracyCircleRadius;
  [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
    self.accuracyDot.layer.transform = CATransform3DIdentity;
    CGFloat scale = accuracyCircleRadius / self.accuracyDot.frame.size.height;
    self.accuracyDot.layer.transform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1.0);
  } completion:nil];
}

#pragma mark Layout

- (void)layoutSubviews {
  [super layoutSubviews];
  self.innerBlueDot.center = CGPointZero;
  self.middleWhiteDot.center = CGPointZero;
  self.outerBlueDot.center = CGPointZero;
  self.accuracyDot.center = CGPointZero;
}

#pragma mark Animation

- (void)_startAnimation {
  [self _animateInnerBlueDot];
  [self _animateOuterBlueDot];
}

- (void)_animateInnerBlueDot {
  MGGPulsingBlueDot __weak *weakSelf = self;
  [UIView animateWithDuration:kInnerBlueDotAnimationTime delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^{
    self.innerBlueDot.layer.transform = CATransform3DScale(CATransform3DIdentity, kInnerBlueDotScaleFactor, kInnerBlueDotScaleFactor, 1.0);
    self.innerBlueDot.backgroundColor = [self _innerDotLargeColor];
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:kInnerBlueDotAnimationTime delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
      self.innerBlueDot.layer.transform = CATransform3DIdentity;
      self.innerBlueDot.backgroundColor = [self _innerDotSmallColor];
    } completion:^(BOOL finished) {
      MGGPulsingBlueDot *strongSelf = weakSelf;
      [strongSelf _animateInnerBlueDot];
    }];
  }];
}

- (void)_animateOuterBlueDot {
  MGGPulsingBlueDot __weak *weakSelf = self;
  [UIView animateWithDuration:1.8 delay:1.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
    self.outerBlueDot.layer.transform = CATransform3DScale(CATransform3DIdentity, kOuterBlueDotScaleFactor, kOuterBlueDotScaleFactor, 1.0);
    self.outerBlueDot.alpha = 0.0;
  } completion:^(BOOL finished) {
    self.outerBlueDot.layer.transform = CATransform3DIdentity;
    self.outerBlueDot.alpha = kOuterBlueDotInitialAlpha;
    MGGPulsingBlueDot *strongSelf = weakSelf;
    [strongSelf _animateOuterBlueDot];
  }];
}

#pragma mark private helpers

- (UIColor *)_innerDotSmallColor {
  if (self.isErrored) {
    return [UIColor colorWithWhite:193.0/255.0 alpha:1.0];
  } else {
    return [UIColor colorWithRed:51.0/255.0 green:148.0/255.0 blue:255.0/255.0 alpha:1.0];
  }
}

- (UIColor *)_innerDotLargeColor {
  if (self.isErrored) {
    return [UIColor colorWithWhite:181.0/255.0 alpha:1.0];
  } else {
    return [UIColor colorWithRed:6.0/255.0 green:124.0/255.0 blue:255.0/255.0 alpha:1.0];
  }
}

@end
