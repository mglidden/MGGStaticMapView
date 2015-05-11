//
//  MGGMapUtils.h
//  MGGStaticMapView
//
//  Created by Mason Glidden on 5/11/15.
//  Copyright (c) 2015 mgg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MGGMapUtils : NSObject

//! Returns YES if the two regions are very close to eachother, to the point where re-drawing the snapshot wouldn't change the visible map region.
+ (BOOL)regionOne:(MKCoordinateRegion)regionOne isNearRegionTwo:(MKCoordinateRegion)regionTwo;

@end
