//
//  MGGDemoAnnotation.m
//  MGGStaticMapViewDemo
//
//  Created by Mason Glidden on 3/14/15.
//  Copyright (c) 2015 mgg. All rights reserved.
//

#import "MGGDemoAnnotation.h"

@interface MGGDemoAnnotation ()
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@end

@implementation MGGDemoAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
  if (self = [super init]) {
    _coordinate = coordinate;
  }
  return self;
}

@end
