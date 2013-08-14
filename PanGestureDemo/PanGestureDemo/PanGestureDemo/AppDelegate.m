//
//  AppDelegate.m
//  PanGestureDemo
//
//  Created by Matthew York on 8/12/13.
//  Copyright (c) 2013 Center for Advanced Public Safety. All rights reserved.
//

#import "AppDelegate.h"
#import "MotionPanGestureRecognizer.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self addPanGesture];
}

-(void)addPanGesture{
    MotionPanGestureRecognizer *panRecognizer = [[MotionPanGestureRecognizer alloc] initWithTarget:self selector:@selector(handlePanGesture:)];
    panRecognizer.numberOfFingersPerHandRequired = 1;
    panRecognizer.numberOfHandsRequired = 1;
    [panRecognizer startListening];
}

-(void)handlePanGesture:(MotionPanGestureRecognizer *)recognizer{
    if (recognizer.state == MotionGestureRecognizerStateBegan) {
        //Do stuff
    }
    else if (recognizer.state == MotionGestureRecognizerStateChanged){
        //Do stuff
        NSLog(@"Did pan   x:%0.4f    y:%0.4f   z:%0.4f", recognizer.centerpoint.x, recognizer.centerpoint.y, recognizer.centerpoint.z);
        
        CGPoint newPoint = [recognizer locationOfVector:recognizer.centerpoint inWindow:self.window scaler:2];
        
        self.SampleImageView.frame = NSRectFromCGRect(CGRectMake(newPoint.x, newPoint.y, self.SampleImageView.frame.size.width, self.SampleImageView.frame.size.height));
    }
    else if (recognizer.state == MotionGestureRecognizerStateEnded){
        
    }
}

@end
