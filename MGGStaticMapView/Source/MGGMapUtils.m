//
//  MGGMapUtils.m
//  MGGStaticMapView
//
//  Created by Mason Glidden on 5/11/15.
//  Copyright (c) 2015 mgg. All rights reserved.
//

#import "MGGMapUtils.h"

@implementation MGGMapUtils

+ (BOOL)regionOne:(MKCoordinateRegion)regionOne isNearRegionTwo:(MKCoordinateRegion)regionTwo {
  static const CGFloat latLongDelta = 0.0001;
  return ABS(regionOne.center.latitude - regionTwo.center.latitude) <= latLongDelta &&
         ABS(regionOne.center.longitude - regionTwo.center.longitude) < latLongDelta &&
         ABS(regionOne.span.latitudeDelta - regionTwo.span.latitudeDelta) < latLongDelta &&
         ABS(regionOne.center.longitude - regionTwo.center.longitude) < latLongDelta;
}

@end
