//
//  MGGUserLocation.m
//  MGGStaticMapView
//
//  Created by Mason Glidden on 5/8/15.
//  Copyright (c) 2015 mgg. All rights reserved.
//

#import "MGGUserLocation.h"

@implementation MGGUserLocation

- (CLLocation *)location {
  return self.currentLocation;
}

@end
