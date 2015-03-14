//
//  ViewController.m
//  MGGStaticMapViewDemo
//
//  Created by Mason Glidden on 3/14/15.
//  Copyright (c) 2015 mgg. All rights reserved.
//

#import "MGGDemoViewController.h"

#import "MGGDemoView.h"

@interface MGGDemoViewController ()
@property (strong, nonatomic) MGGDemoView *demoView;
@end

@implementation MGGDemoViewController

- (void)loadView {
  if (!self.demoView) {
    self.demoView = [[MGGDemoView alloc] init];
  }
  self.view = self.demoView;
}

@end
