//
//  MGGMapView.m
//  MGGStaticMapView
//
//  Created by Mason Glidden on 3/14/15.
//  Copyright (c) 2015 mgg. All rights reserved.
//

#import "MGGMapView.h"

#import "MGGPulsingBlueDot.h"

#import <MapKit/MKMapSnapshotter.h>

@interface MGGMapView () <CLLocationManagerDelegate>
@property (strong, nonatomic) MKMapSnapshotter *snapshotter;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKMapSnapshot *snapshot;

@property (strong, nonatomic) UIImageView *mapImageView;

@property (strong, nonatomic) CLLocation *lastUserLocation;
@property (strong, nonatomic) MGGPulsingBlueDot *blueDot;
@property (strong, nonatomic) NSLayoutConstraint *leftDotConstraint;
@property (strong, nonatomic) NSLayoutConstraint *topDotConstraint;
@end

@implementation MGGMapView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:245.0/255.0 blue:237.0/255.0 alpha:1.0];
    self.clipsToBounds = YES;
    
    _locationManager = [[CLLocationManager alloc] init];
    
    _mapImageView = [[UIImageView alloc] init];
    _mapImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_mapImageView];
    
    _blueDot = [[MGGPulsingBlueDot alloc] init];
    _blueDot.translatesAutoresizingMaskIntoConstraints = NO;
    _blueDot.hidden = YES;
    [self addSubview:_blueDot];
    
    [self _installConstraints];
  }
  return self;
}

- (void)_installConstraints {
  NSDictionary *views = NSDictionaryOfVariableBindings(_mapImageView);
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mapImageView]|" options:0 metrics:nil views:views]];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mapImageView]|" options:0 metrics:nil views:views]];
  
  self.leftDotConstraint = [NSLayoutConstraint constraintWithItem:self.blueDot attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:30.0];
  self.topDotConstraint = [NSLayoutConstraint constraintWithItem:self.blueDot attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:30.0];
  [self addConstraints:@[self.leftDotConstraint, self.topDotConstraint]];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  if (!CGSizeEqualToSize(self.mapImageView.image.size, self.mapImageView.frame.size) &&
      !CGSizeEqualToSize(self.mapImageView.frame.size, CGSizeZero)) {
    [self takeSnapshot];
  }
}

- (void)takeSnapshot {
  [self.snapshotter cancel];
  self.snapshot = nil;
  self.mapImageView.image = nil;
  self.mapImageView.alpha = 0.0;
  
  MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
  options.mapType = self.mapType;
  options.region = self.region;
  options.size = self.frame.size;
  options.showsPointsOfInterest = self.showsPointsOfInterest;
  options.showsBuildings = self.showsBuildings;
  
  self.snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
  [self.snapshotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.snapshot = snapshot;
      self.mapImageView.image = snapshot.image;
      [UIView animateWithDuration:0.25 animations:^{
        self.mapImageView.alpha = 1.0;
      }];
    });
  }];
}

- (void)setLastUserLocation:(CLLocation *)lastUserLocation {
  _lastUserLocation = lastUserLocation;
  if (self.snapshot) {
    [self _updateBlueDotPosition];
  }
}

- (void)setSnapshot:(MKMapSnapshot *)snapshot {
  _snapshot = snapshot;
  if (self.lastUserLocation) {
    [self _updateBlueDotPosition];
  }
}

- (void)_updateBlueDotPosition {
  CGPoint blueDotPoint = [self.snapshot pointForCoordinate:self.lastUserLocation.coordinate];
  self.leftDotConstraint.constant = blueDotPoint.x;
  self.topDotConstraint.constant = blueDotPoint.y;
  self.blueDot.hidden = NO;
}

#pragma mark Public Setters

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate {
  _centerCoordinate = centerCoordinate;
  self.region = MKCoordinateRegionMake(centerCoordinate, self.region.span);
}

- (void)setShowsUserLocation:(BOOL)showsUserLocation {
  _showsUserLocation = showsUserLocation;
  
  if (!_showsUserLocation) {
    return;
  }
  
  CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
  if (status == kCLAuthorizationStatusAuthorized || status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
  } else {
    NSLog(@"Must ask for location authorization first.");
  }
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  // todo start getting location here
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  self.lastUserLocation = locations.lastObject;
}

@end
