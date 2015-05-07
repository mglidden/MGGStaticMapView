//
//  MGGMapView.h
//  MGGStaticMapView
//
//  Created by Mason Glidden on 3/14/15.
//  Copyright (c) 2015 mgg. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

@interface MGGMapView : UIView

@property (nonatomic, assign) MKMapType mapType;
@property (nonatomic, assign) MKCoordinateRegion region;
@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic) BOOL showsPointsOfInterest;
@property (nonatomic) BOOL showsBuildings;
@property (nonatomic) BOOL showsUserLocation;

- (void)addAnnotation:(id <MKAnnotation>)annotation;
- (void)addAnnotations:(NSArray *)annotations;

- (void)removeAnnotation:(id <MKAnnotation>)annotation;
- (void)removeAnnotations:(NSArray *)annotations;

@property (nonatomic, readonly) NSArray *annotations;

@property (weak, nonatomic) id<MKMapViewDelegate> delegate;

@end
