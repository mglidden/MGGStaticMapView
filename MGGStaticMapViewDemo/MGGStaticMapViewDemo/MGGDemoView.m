//
//  MGGDemoView.m
//  MGGStaticMapView
//
//  Created by Mason Glidden on 3/14/15.
//  Copyright (c) 2015 mgg. All rights reserved.
//

#import "MGGDemoView.h"

#import "MGGDemoAnnotation.h"

#import <MGGStaticMapView/MGGStaticMapView.h>

@interface MGGDemoView ()
@property (strong, nonatomic) MGGStaticMapView *staticMapView;
@property (strong, nonatomic) MKMapView *liveMapView;
@end

@implementation MGGDemoView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor whiteColor];
    
    _staticMapView = [[MGGStaticMapView alloc] init];
    _staticMapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self _setupMapView:(MKMapView *)_staticMapView];
    [self addSubview:_staticMapView];
    
    _liveMapView = [[MKMapView alloc] init];
    _liveMapView.translatesAutoresizingMaskIntoConstraints = NO;
    _liveMapView.pitchEnabled = NO;
    _liveMapView.zoomEnabled = NO;
    _liveMapView.scrollEnabled = NO;
    _liveMapView.rotateEnabled = NO;
    [self _setupMapView:_liveMapView];
    [self addSubview:_liveMapView];
    
    [self _installConstraints];
  }
  return self;
}

- (void)_setupMapView:(MKMapView *)mapView {
  mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.7833, -122.4167), MKCoordinateSpanMake(0.02, 0.02));
  mapView.showsPointsOfInterest = NO;
  mapView.showsBuildings = YES;
  mapView.showsUserLocation = YES;
  [mapView addAnnotations:[[self class] _annotations]];
}

- (void)_installConstraints {
  NSDictionary *views = NSDictionaryOfVariableBindings(_staticMapView, _liveMapView);
  NSDictionary *metrics = @{@"topMargin": @50, @"mapHeight": @75, @"mapMargin": @15};
  
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_staticMapView]|" options:0 metrics:metrics views:views]];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_liveMapView]|" options:0 metrics:metrics views:views]];
  
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[_staticMapView(mapHeight)]-mapMargin-[_liveMapView(mapHeight)]" options:0 metrics:metrics views:views]];
}

+ (NSArray *)_annotations {
  return @[
           [[MGGDemoAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.78, -122.41)],
           [[MGGDemoAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(3.78, -12.41)],
           ];
}

@end
