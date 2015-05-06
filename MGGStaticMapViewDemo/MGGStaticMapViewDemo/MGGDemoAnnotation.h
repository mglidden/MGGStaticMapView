//
//  MGGDemoAnnotation.h
//  MGGStaticMapViewDemo
//
//  Created by Mason Glidden on 3/14/15.
//  Copyright (c) 2015 mgg. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

@interface MGGDemoAnnotation : UIView <MKAnnotation>

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
