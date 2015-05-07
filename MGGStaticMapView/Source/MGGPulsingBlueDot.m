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

@interface MGGPulsingBlueDot ()
@property (strong, nonatomic) UIView *outerBlueDot;
@property (strong, nonatomic) UIView *middleWhiteDot;
@property (strong, nonatomic) UIView *innerBlueDot;
@end

@implementation MGGPulsingBlueDot

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.clipsToBounds = NO;
    
    _outerBlueDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kOuterBlueDotInitialDimension, kOuterBlueDotInitialDimension)];
    _outerBlueDot.backgroundColor = [[self class] _smallColor];
    _outerBlueDot.alpha = 0.5;
    _outerBlueDot.layer.cornerRadius = kOuterBlueDotInitialDimension / 2.0;
    [self addSubview:_outerBlueDot];
    
    _middleWhiteDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kOuterDotDimension, kOuterDotDimension)];
    _middleWhiteDot.backgroundColor = [UIColor whiteColor];
    _middleWhiteDot.layer.cornerRadius = kOuterDotDimension / 2.0;
    _middleWhiteDot.layer.shadowColor = [UIColor blackColor].CGColor;
    _middleWhiteDot.layer.shadowRadius = 10.0;
    _middleWhiteDot.layer.shadowOpacity = 0.2;
    [self addSubview:_middleWhiteDot];
    
    _innerBlueDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kInnerBlueDotDimension, kInnerBlueDotDimension)];
    _innerBlueDot.backgroundColor = [[self class] _smallColor];
    _innerBlueDot.layer.cornerRadius = kOuterDotDimension * kInnerBlueDotRelativeMinSize / 2.0;
    [self addSubview:_innerBlueDot];
    
    [self _startAnimation];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.innerBlueDot.center = CGPointZero;
  self.middleWhiteDot.center = CGPointZero;
  self.outerBlueDot.center = CGPointZero;
}

- (void)_startAnimation {
  [self _animateInnerBlueDot];
  [self _animateOuterBlueDot];
}

- (void)_animateInnerBlueDot {
  MGGPulsingBlueDot __weak *weakSelf = self;
  [UIView animateWithDuration:kInnerBlueDotAnimationTime delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^{
    self.innerBlueDot.layer.transform = CATransform3DScale(CATransform3DIdentity, kInnerBlueDotScaleFactor, kInnerBlueDotScaleFactor, 1.0);
    self.innerBlueDot.backgroundColor = [[self class] _largeColor];
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:kInnerBlueDotAnimationTime delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
      self.innerBlueDot.layer.transform = CATransform3DIdentity;
      self.innerBlueDot.backgroundColor = [[self class] _smallColor];
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
    self.outerBlueDot.alpha = 0.5;
    MGGPulsingBlueDot *strongSelf = weakSelf;
    [strongSelf _animateOuterBlueDot];
  }];
}

+ (UIColor *)_smallColor {
  return [UIColor colorWithRed:51.0/255.0 green:148.0/255.0 blue:255.0/255.0 alpha:1.0];
}

+ (UIColor *)_largeColor {
  return [UIColor colorWithRed:6.0/255.0 green:124.0/255.0 blue:255.0/255.0 alpha:1.0];
}

@end
