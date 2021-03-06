//
//  MGGPulsingBlueDot.h
//  MGGStaticMapView
//
//  Created by Mason Glidden on 3/14/15.
//  Copyright (c) 2015 mgg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MGGPulsingBlueDot : MKAnnotationView

@property (assign, nonatomic, getter=isErrored) BOOL errored;
@property (assign, nonatomic) CGFloat accuracyCircleRadius;
@property (assign, nonatomic, getter=isAnimating) BOOL animating;

@end
