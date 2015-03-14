//
//  MGGDemoView.m
//  MGGStaticMapView
//
//  Created by Mason Glidden on 3/14/15.
//  Copyright (c) 2015 mgg. All rights reserved.
//

#import "MGGDemoView.h"

#import "MGGMapView.h"

@interface MGGDemoView ()
@property (strong, nonatomic) UIView *staticMapView;
@end

@implementation MGGDemoView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor whiteColor];
    
    _staticMapView = [[MGGMapView alloc] init];
    _staticMapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_staticMapView];
    
    [self _installConstraints];
  }
  return self;
}

- (void)_installConstraints {
  NSDictionary *views = NSDictionaryOfVariableBindings(_staticMapView);
  NSDictionary *metrics = @{@"topMargin": @50, @"mapHeight": @200};
  
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_staticMapView]|" options:0 metrics:metrics views:views]];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[_staticMapView(mapHeight)]" options:0 metrics:metrics views:views]];
}

@end
