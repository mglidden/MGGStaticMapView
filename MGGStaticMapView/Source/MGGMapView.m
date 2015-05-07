//
//  MGGMapView.m
//  MGGStaticMapView
//
//  Created by Mason Glidden on 3/14/15.
//  Copyright (c) 2015 mgg. All rights reserved.
//

#import "MGGMapView.h"

#import "MGGPulsingBlueDot.h"

BOOL equalRegions(MKCoordinateRegion regionOne, MKCoordinateRegion regionTwo) {
  return regionOne.span.latitudeDelta == regionTwo.span.latitudeDelta && regionOne.span.longitudeDelta == regionTwo.span.longitudeDelta && regionOne.center.latitude == regionTwo.center.latitude && regionOne.center.longitude == regionTwo.center.longitude;
}

@interface MGGMapView () <CLLocationManagerDelegate>
@property (strong, nonatomic) MKMapSnapshotter *snapshotter;
@property (strong, nonatomic) MKMapSnapshotOptions *snapshotterOptions;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKMapSnapshot *snapshot;

@property (strong, nonatomic) UIImageView *mapImageView;

@property (strong, nonatomic) CLLocation *lastUserLocation;
@property (strong, nonatomic) MGGPulsingBlueDot *blueDot;

@property (strong, nonatomic) NSMutableArray *mutableAnnotations;
@property (strong, nonatomic) NSMutableDictionary *annotationToAnnotationView;
@end

@implementation MGGMapView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:245.0/255.0 blue:237.0/255.0 alpha:1.0];
    self.clipsToBounds = YES;
    
    _showsPointsOfInterest = YES;
    _showsBuildings = YES;
    
    _locationManager = [[CLLocationManager alloc] init];
    _mutableAnnotations = [NSMutableArray array];
    _annotationToAnnotationView = [NSMutableDictionary dictionary];
    
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
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  [self _takeSnapshotIfNeeded];
}

- (void)_takeSnapshotIfNeeded {
  // If none of the settings have changed, we don't need to take another snapshot
  if (CGSizeEqualToSize(self.frame.size, self.snapshotterOptions.size) &&
      self.snapshotterOptions != nil &&
      equalRegions(self.snapshotterOptions.region, self.region) &&
      self.region.span.longitudeDelta > 0 &&
      self.region.span.latitudeDelta > 0 &&
      self.snapshotterOptions.showsPointsOfInterest == self.showsPointsOfInterest &&
      self.snapshotterOptions.showsBuildings == self.showsBuildings &&
      self.snapshotterOptions.mapType == self.mapType) {
    return;
  }
  
  // Make sure all of the data is correct before we take a snapshot
  if (CGSizeEqualToSize(self.mapImageView.frame.size, CGSizeZero) ||
      self.region.span.longitudeDelta <= 0.0 ||
      self.region.span.latitudeDelta <= 0.0) {
    return;
  }
  
  [self.snapshotter cancel];
  self.snapshot = nil;
  self.mapImageView.image = nil;
  self.mapImageView.alpha = 0.0;
  
  self.snapshotterOptions = [[MKMapSnapshotOptions alloc] init];
  self.snapshotterOptions.mapType = self.mapType;
  self.snapshotterOptions.region = self.region;
  self.snapshotterOptions.size = self.frame.size;
  self.snapshotterOptions.showsPointsOfInterest = self.showsPointsOfInterest;
  self.snapshotterOptions.showsBuildings = self.showsBuildings;
  
  self.snapshotter = [[MKMapSnapshotter alloc] initWithOptions:self.snapshotterOptions];
  [self.snapshotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.snapshot = snapshot;
      self.mapImageView.image = snapshot.image;
      [UIView animateWithDuration:0.2 animations:^{
        self.mapImageView.alpha = 1.0;
      }];
    });
  }];
}

- (void)setLastUserLocation:(CLLocation *)lastUserLocation {
  _lastUserLocation = lastUserLocation;
  if (self.snapshot) {
    [self _updateBlueDotPosition];
    [self _updateAnnotationPositions];
  }
}

- (void)setSnapshot:(MKMapSnapshot *)snapshot {
  _snapshot = snapshot;
  if (self.lastUserLocation) {
    [self _updateBlueDotPosition];
  }
  [self _updateAnnotationPositions];
}

- (void)_updateBlueDotPosition {
  self.blueDot.center = [self.snapshot pointForCoordinate:self.lastUserLocation.coordinate];
  self.blueDot.hidden = NO;
}

- (void)_updateAnnotationPositions {
  for (id<MKAnnotation> annotation in self.annotations) {
    MKAnnotationView *annotationView = self.annotationToAnnotationView[[[self class] _hashForAnnotation:annotation]];
    if (self.snapshot) {
      CGPoint annotationPoint = [self.snapshot pointForCoordinate:annotation.coordinate];
      annotationPoint.x += annotationView.centerOffset.x;
      annotationPoint.y += annotationView.centerOffset.y;
      annotationView.center = annotationPoint;
      annotationView.hidden = NO;
    } else {
      annotationView.hidden = YES;
    }
  }
}

#pragma mark Public Setters

- (void)setRegion:(MKCoordinateRegion)region {
  if (!equalRegions(region, _region)) {
    _region = region;
    [self _takeSnapshotIfNeeded];
  }
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate {
  _centerCoordinate = centerCoordinate;
  self.region = MKCoordinateRegionMake(centerCoordinate, self.region.span);
}

- (void)setShowsUserLocation:(BOOL)showsUserLocation {
  _showsUserLocation = showsUserLocation;
  
  if (!_showsUserLocation) {
    self.blueDot.hidden = YES;
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

- (void)setShowsPointsOfInterest:(BOOL)showsPointsOfInterest {
  _showsPointsOfInterest = showsPointsOfInterest;
  [self _takeSnapshotIfNeeded];
}

- (void)setShowsBuildings:(BOOL)showsBuildings {
  _showsBuildings = showsBuildings;
  [self _takeSnapshotIfNeeded];
}

- (void)setMapType:(MKMapType)mapType {
  _mapType = mapType;
  [self _takeSnapshotIfNeeded];
}

#pragma mark Annotations

- (void)addAnnotation:(id <MKAnnotation>)annotation {
  [self.mutableAnnotations addObject:annotation];
  [self _addAnnotations:@[annotation]];
}

- (void)addAnnotations:(NSArray *)annotations {
  [self.mutableAnnotations addObjectsFromArray:annotations];
  [self _addAnnotations:annotations];
}

- (void)removeAnnotation:(id <MKAnnotation>)annotation {
  [self.mutableAnnotations removeObject:annotation];
  [self _removeAnnotations:@[annotation]];
}

- (void)removeAnnotations:(NSArray *)annotations {
  [self.mutableAnnotations removeObjectsInArray:annotations];
  [self _removeAnnotations:annotations];
}

- (NSArray *)annotations {
  return [self.mutableAnnotations copy];
}

- (void)_addAnnotations:(NSArray *)annotations {
  for (id<MKAnnotation> annotation in annotations) {
    id<MKMapViewDelegate> delegate = self.delegate;
    MKAnnotationView *annotationView = nil;
    if ([delegate respondsToSelector:@selector(mapView:viewForAnnotation:)]) {
      annotationView = [delegate mapView:nil viewForAnnotation:annotation];
    } else {
      annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    }
    self.annotationToAnnotationView[[[self class] _hashForAnnotation:annotation]] = annotationView;
    
    [self addSubview:annotationView];
  }
  [self _updateAnnotationPositions];
}

- (void)_removeAnnotations:(NSArray *)annotations {
  for (id<MKAnnotation> annotation in annotations) {
    MKAnnotationView *annotationView = self.annotationToAnnotationView[annotation];
    [self.annotationToAnnotationView removeObjectForKey:[[self class] _hashForAnnotation:annotation]];
    [annotationView removeFromSuperview];
  }
}

+ (NSNumber *)_hashForAnnotation:(id<MKAnnotation>)annotation {
  CLLocationCoordinate2D coordinate = [annotation coordinate];
  return @(@(coordinate.latitude).hash + @(coordinate.longitude).hash);
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  // todo start getting location here
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  self.blueDot.errored = NO;
  CLLocation *newLocation = locations.lastObject;
  if (self.lastUserLocation.coordinate.latitude != newLocation.coordinate.latitude || self.lastUserLocation.coordinate.longitude != newLocation.coordinate.longitude || self.lastUserLocation.horizontalAccuracy != newLocation.horizontalAccuracy) {
    self.lastUserLocation = locations.lastObject;
  }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  self.blueDot.errored = YES;
}

@end
