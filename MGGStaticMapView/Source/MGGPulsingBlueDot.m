//
//  MGGPulsingBlueDot.m
//  MGGStaticMapView
//
//  Created by Mason Glidden on 3/14/15.
//  Copyright (c) 2015 mgg. All rights reserved.
//

#import "MGGPulsingBlueDot.h"

static const CGFloat kMiddleWhiteDotDimension = 22.0;

static const CGFloat kInnerBlueDotRelativeMinSize = 0.59;
static const CGFloat kInnerBlueDotRelativeMaxSize = 0.72;
static const CGFloat kInnerBlueDotScaleFactor = kInnerBlueDotRelativeMaxSize / kInnerBlueDotRelativeMinSize;
static const CGFloat kInnerBlueDotDimension = kMiddleWhiteDotDimension * kInnerBlueDotRelativeMinSize;
static const CGFloat kInnerBlueDotAnimationTime = 1.2;

static const CGFloat kOuterBlueDotInitialDimension = kMiddleWhiteDotDimension;
static const CGFloat kOuterBlueDotMaxScaleFactor = 5.5;
static const CGFloat kOuterBlueDotInitialAlpha = 0.5;

static const CGFloat kAccuracyDotInitialDimension = kMiddleWhiteDotDimension;
static const CGFloat kAccuracyDotMinimumScaleFactor = 1.5; // Minimum size, under which we won't show the accuracy dot

@interface MGGPulsingBlueDot ()
@property (strong, nonatomic) UIView *accuracyDot;
@property (assign, nonatomic) CGFloat accuracyDotScale;
@property (strong, nonatomic) UIView *outerBlueDot;
@property (strong, nonatomic) UIView *middleWhiteDot;
@property (strong, nonatomic) UIView *innerBlueDot;
@end

@implementation MGGPulsingBlueDot

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.clipsToBounds = NO;
    
    _accuracyDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAccuracyDotInitialDimension, kAccuracyDotInitialDimension)];
    _accuracyDot.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:148.0/255.0 blue:255.0/255.0 alpha:1.0];
    _accuracyDot.alpha = 0.2;
    _accuracyDot.layer.cornerRadius = _accuracyDot.frame.size.height / 2.0;
    [self addSubview:_accuracyDot];
    
    _outerBlueDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kOuterBlueDotInitialDimension, kOuterBlueDotInitialDimension)];
    _outerBlueDot.backgroundColor = _accuracyDot.backgroundColor;
    _outerBlueDot.alpha = kOuterBlueDotInitialAlpha;
    _outerBlueDot.layer.cornerRadius = _outerBlueDot.frame.size.height / 2.0;
    [self addSubview:_outerBlueDot];
    
    _middleWhiteDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMiddleWhiteDotDimension, kMiddleWhiteDotDimension)];
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
  void (^animationBlock)() = ^{
    self.accuracyDot.layer.transform = CATransform3DIdentity;
    self.accuracyDotScale = accuracyCircleRadius / self.accuracyDot.frame.size.height;
    self.accuracyDot.layer.transform = CATransform3DScale(CATransform3DIdentity, self.accuracyDotScale, self.accuracyDotScale, 1.0);
    self.accuracyDot.hidden = self.accuracyDotScale < kAccuracyDotMinimumScaleFactor;
  };
  if (self.accuracyDotScale == 0.0) {
    animationBlock();
  } else {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:animationBlock completion:nil];
  }
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
  // I would love to use a keyframe animation here, but keyframes don't support ease in and ease out (specifically, I would need it to change from ease-out to ease-in halfway through).
  MGGPulsingBlueDot *__weak weakSelf = self;
  [UIView animateWithDuration:kInnerBlueDotAnimationTime delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^{
    self.innerBlueDot.layer.transform = CATransform3DScale(CATransform3DIdentity, kInnerBlueDotScaleFactor, kInnerBlueDotScaleFactor, 1.0);
    self.innerBlueDot.backgroundColor = [self _innerDotLargeColor];
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:kInnerBlueDotAnimationTime delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
      MGGPulsingBlueDot *strongSelf = weakSelf;
      strongSelf.innerBlueDot.layer.transform = CATransform3DIdentity;
      strongSelf.innerBlueDot.backgroundColor = [strongSelf _innerDotSmallColor];
    } completion:^(BOOL finished) {
      MGGPulsingBlueDot *strongSelf = weakSelf;
      [strongSelf _animateInnerBlueDot];
    }];
  }];
}

- (void)_animateOuterBlueDot {
  MGGPulsingBlueDot *__weak weakSelf = self;
  [UIView animateWithDuration:1.8 delay:1.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
    CGFloat scale = kOuterBlueDotMaxScaleFactor;
    // If the accuracy dot is big enough, the outer blue dot should only animate to the radius of the accuracy dot.
    if (self.accuracyDotScale > kAccuracyDotMinimumScaleFactor) {
      // If the accuracy dot is too big, we don't want to animate the outer blue dot anymore
      if (self.accuracyDotScale > kOuterBlueDotMaxScaleFactor) {
        scale = 0.0;
      } else {
        scale = self.accuracyDotScale;
      }
    }
    self.outerBlueDot.layer.transform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1.0);
    self.outerBlueDot.alpha = 0.0;
  } completion:^(BOOL finished) {
    MGGPulsingBlueDot *strongSelf = weakSelf;
    weakSelf.outerBlueDot.layer.transform = CATransform3DIdentity;
    weakSelf.outerBlueDot.alpha = kOuterBlueDotInitialAlpha;
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
