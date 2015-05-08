//
//  MGGUserLocation.h
//  MGGStaticMapView
//
//  Created by Mason Glidden on 5/8/15.
//  Copyright (c) 2015 mgg. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MGGUserLocation : MKUserLocation

//! Returns nil if the owning MKMapView's showsUserLocation is NO or the user's location has yet to be determined.
@property (strong, nonatomic) CLLocation *currentLocation;

@end
