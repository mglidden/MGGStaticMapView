//
//  MGGMapView.m
//  MGGStaticMapView
//
//  Created by Mason Glidden on 3/14/15.
//  Copyright (c) 2015 mgg. All rights reserved.
//

#import "MGGStaticMapView.h"

#import "MGGPulsingBlueDot.h"
#import "MGGMutableUserLocation.h"
#import "MGGMapUtils.h"

@interface MGGStaticMapView () <CLLocationManagerDelegate>
@property (strong, nonatomic) MKMapSnapshotter *snapshotter;
@property (strong, nonatomic) MKMapSnapshotOptions *snapshotterOptions;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKMapSnapshot *snapshot;

@property (strong, nonatomic) UIImageView *mapImageView;

@property (strong, nonatomic) MGGPulsingBlueDot *blueDot;

@property (strong, nonatomic) MGGMutableUserLocation *mutableUserLocation;
@property (strong, nonatomic) NSMutableOrderedSet *mutableAnnotations;
@property (strong, nonatomic) NSMutableDictionary *annotationToAnnotationView;
@end

@implementation MGGStaticMapView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:245.0/255.0 blue:237.0/255.0 alpha:1.0];
    self.clipsToBounds = YES;
    
    _showsPointsOfInterest = YES;
    _showsBuildings = YES;
    
    _locationManager = [[CLLocationManager alloc] init];
    _mutableAnnotations = [NSMutableOrderedSet orderedSet];
    _annotationToAnnotationView = [NSMutableDictionary dictionary];
    
    _mapImageView = [[UIImageView alloc] init];
    _mapImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_mapImageView];
    
    _mutableUserLocation = [[MGGMutableUserLocation alloc] init];
    _blueDot = [[MGGPulsingBlueDot alloc] init];
    
    [self _installConstraints];
  }
  return self;
}

- (void)dealloc {
  _locationManager.delegate = nil;
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

- (void)willMoveToWindow:(UIWindow *)newWindow {
  [super willMoveToWindow:newWindow];
  // We need to stop the animating when the view gets taken off screen, otherwise CPU will throttle to 100%
  self.blueDot.animating = (newWindow != nil);
}

- (void)_takeSnapshotIfNeeded {
  // If none of the settings have changed, we don't need to take another snapshot
  if (CGSizeEqualToSize(self.frame.size, self.snapshotterOptions.size) &&
      self.snapshotterOptions != nil &&
      [MGGMapUtils regionOne:self.snapshotterOptions.region isNearRegionTwo:self.region] &&
      self.region.span.longitudeDelta > 0 &&
      self.region.span.latitudeDelta > 0 &&
      self.snapshotterOptions.showsPointsOfInterest == self.showsPointsOfInterest &&
      self.snapshotterOptions.showsBuildings == self.showsBuildings &&
      self.snapshotterOptions.mapType == self.mapType) {
    return;
  }
  
  // Make sure all of the data is correct before we take a snapshot
  if (self.frame.size.height <= 0.0 ||
      self.frame.size.width <= 0.0 ||
      self.region.span.longitudeDelta <= 0.0 ||
      self.region.span.latitudeDelta <= 0.0) {
    return;
  }
  
  self.snapshot = nil;
  self.mapImageView.image = nil;
  self.mapImageView.alpha = 0.0;
  [self _updateAnnotations]; // hides the annotations while the snapshot is being taken.
  
  self.snapshotterOptions = [[MKMapSnapshotOptions alloc] init];
  self.snapshotterOptions.mapType = self.mapType;
  self.snapshotterOptions.region = self.region;
  self.snapshotterOptions.size = self.frame.size;
  self.snapshotterOptions.showsPointsOfInterest = self.showsPointsOfInterest;
  self.snapshotterOptions.showsBuildings = self.showsBuildings;
  
  MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:self.snapshotterOptions];
  self.snapshotter = snapshotter;
  MGGStaticMapView *__weak weakSelf = self;
  [self.snapshotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      MGGStaticMapView *strongSelf = weakSelf;
      
      // MKSnapshotter doesn't like it when you call cancel, so we have to check that self.snapshotter hasn't changed by the time the image comes back.
      // http://www.openradar.appspot.com/17363235
      if (strongSelf.snapshotter != snapshotter) {
        return;
      }
      
      strongSelf.snapshot = snapshot;
      strongSelf.mapImageView.image = snapshot.image;
      [UIView animateWithDuration:0.2 animations:^{
        strongSelf.mapImageView.alpha = 1.0;
      }];
    });
  }];
}

- (void)setSnapshot:(MKMapSnapshot *)snapshot {
  if (_snapshot != snapshot) {
    _snapshot = snapshot;
    [self _updateUserLocationAnnotation];
    [self _updateAnnotations];
  }
}

- (void)_updateUserLocationAnnotation {
  if (self.userLocation.location && self.snapshot) {
    self.blueDot.hidden = NO;
    
    CGPoint userLocationPoint = [self.snapshot pointForCoordinate:self.userLocation.location.coordinate];
    self.blueDot.center = userLocationPoint;
    
    CLLocation *testLocation = [[CLLocation alloc] initWithLatitude:self.userLocation.location.coordinate.latitude + 0.001 longitude:self.userLocation.location.coordinate.longitude];
    CLLocationDistance distanceInMeters = fabs([testLocation distanceFromLocation:self.userLocation.location]);
    CGFloat distanceInPoints = fabs(userLocationPoint.y - [self.snapshot pointForCoordinate:testLocation.coordinate].y);
    CGFloat pointsPerMeter = distanceInPoints / distanceInMeters;
    CGFloat horizontalAccuracyPoints = pointsPerMeter * self.userLocation.location.horizontalAccuracy;
    self.blueDot.accuracyCircleRadius = horizontalAccuracyPoints;
  } else {
    self.blueDot.hidden = YES;
  }
}

#pragma mark Annotations

- (void)_updateAnnotations {
  for (id<MKAnnotation> annotation in self.annotations) {
    [self _updatePositionForAnnotation:annotation];
  }
}

- (void)_updatePositionForAnnotation:(id<MKAnnotation>)annotation {
  MKAnnotationView *annotationView = self.annotationToAnnotationView[[[self class] _hashForAnnotation:annotation]];
  if (annotation == self.userLocation) {
    [self _updateUserLocationAnnotation];
  } else if (self.snapshot) {
    CGPoint annotationPoint = [self.snapshot pointForCoordinate:annotation.coordinate];
    annotationPoint.x += annotationView.centerOffset.x;
    annotationPoint.y += annotationView.centerOffset.y;
    annotationView.center = annotationPoint;
    annotationView.hidden = NO;
  } else {
    annotationView.hidden = YES;
  }
}

#pragma mark Public Properties

- (void)setRegion:(MKCoordinateRegion)region {
  if (![MGGMapUtils regionOne:region isNearRegionTwo:_region]) {
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
    [self removeAnnotation:self.userLocation];
    self.mutableUserLocation.currentLocation = nil;
    [self.locationManager stopUpdatingLocation];
    return;
  } else {
    [self addAnnotation:self.userLocation];
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

- (MKUserLocation *)userLocation {
  return self.mutableUserLocation;
}

#pragma mark Annotations

- (void)addAnnotation:(id <MKAnnotation>)annotation {
  [self addAnnotations:@[annotation]];
}

- (void)addAnnotations:(NSArray *)annotations {
  [self _addAnnotations:annotations];
}

- (void)removeAnnotation:(id <MKAnnotation>)annotation {
  [self removeAnnotations:@[annotation]];
}

- (void)removeAnnotations:(NSArray *)annotations {
  [self _removeAnnotations:annotations];
}

- (NSArray *)annotations {
  return [self.mutableAnnotations array];
}

- (void)_addAnnotations:(NSArray *)annotations {
  [self.mutableAnnotations addObjectsFromArray:annotations];
  
  for (id<MKAnnotation> annotation in annotations) {
    id<MKMapViewDelegate> delegate = self.delegate;
    MKAnnotationView *annotationView = self.annotationToAnnotationView[[[self class] _hashForAnnotation:annotation]];
    if (annotationView == nil) {
      if ([delegate respondsToSelector:@selector(mapView:viewForAnnotation:)]) {
        annotationView = [delegate mapView:nil viewForAnnotation:annotation];
      }
      // If the delegate doesn't want to provide an annotation view, we'll fall back to some defaults.
      if (annotationView == nil) {
        if (annotation == self.userLocation){
          annotationView = self.blueDot;
        } else {
          annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        }
      }
      self.annotationToAnnotationView[[[self class] _hashForAnnotation:annotation]] = annotationView;
      
      [self addSubview:annotationView];
    }
    [self _updatePositionForAnnotation:annotation];
  }
}

- (void)_removeAnnotations:(NSArray *)annotations {
  // In case someone did [mapView removeAnnotations:mapView.annotations] we'll need to make a copy of annotations before mutating things.
  NSArray *annotationsToRemove = [annotations copy];
  [self.mutableAnnotations removeObjectsInArray:annotationsToRemove];
  for (id<MKAnnotation> annotation in annotationsToRemove) {
    NSNumber *hashKey = [[self class] _hashForAnnotation:annotation];
    [self.annotationToAnnotationView[hashKey] removeFromSuperview];
    [self.annotationToAnnotationView removeObjectForKey:hashKey];
  }
}

+ (NSNumber *)_hashForAnnotation:(id<MKAnnotation>)annotation {
  // TODO: make this better
  CLLocationCoordinate2D coordinate = [annotation coordinate];
  return @(@(coordinate.latitude).hash + @(coordinate.longitude).hash);
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (status == kCLAuthorizationStatusAuthorized) {
    [self.locationManager startUpdatingLocation];
  }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  self.blueDot.errored = NO;
  CLLocation *newLocation = locations.lastObject;
  CLLocation *lastLocation = self.userLocation.location;
  if (lastLocation.coordinate.latitude != newLocation.coordinate.latitude || lastLocation.coordinate.longitude != newLocation.coordinate.longitude || lastLocation.horizontalAccuracy != newLocation.horizontalAccuracy) {
    self.mutableUserLocation.currentLocation = locations.lastObject;
    [self _updateUserLocationAnnotation];
  }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  self.blueDot.errored = YES;
}

@end
