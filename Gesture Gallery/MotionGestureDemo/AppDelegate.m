//  Copyright (c) 2012 The Board of Trustees of The University of Alabama
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. Neither the name of the University nor the names of the contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
//  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
//  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
//  OF THE POSSIBILITY OF SUCH DAMAGE.

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self addPanGesture];
    [self addSwipeGesture];
    [self addTapGesture];
    [self addPinchGesture];
    //[self addRotationGesture];
}

#pragma mark - Gesture Creation

-(void)addPanGesture{
    panRecognizer = [[MotionPanGestureRecognizer alloc] initWithTarget:self selector:@selector(handlePanGesture:)];
    panRecognizer.numberOfFingersPerHandRequired = 1;
    panRecognizer.numberOfHandsRequired = 1;
    [panRecognizer startListening];
}

-(void)addSwipeGesture{
    swipeRecognizer = [[MotionSwipeGestureRecognizer alloc] initWithTarget:self selector:@selector(handleSwipeGesture:)];
    swipeRecognizer.numberOfFingersPerHandRequired = 3;
    swipeRecognizer.numberOfHandsRequired = 1;
    swipeRecognizer.possibleDirections = MotionSwipeGestureRecognizerDirectionRight | MotionSwipeGestureRecognizerDirectionLeft;
    [swipeRecognizer startListening];
}

-(void)addTapGesture{
    tapRecognizer = [[MotionTapGestureRecognizer alloc] initWithTarget:self selector:@selector(handleTapGesture:)];
    tapRecognizer.numberOfHandsRequired = 1;
    tapRecognizer.numberOfFingersPerHandRequired = 1;
    tapRecognizer.possibleDirections = MotionTapGestureRecognizerDirectionDown | MotionTapGestureRecognizerDirectionUp;
    [tapRecognizer startListening];
}

-(void)addPinchGesture{
    pinchRecognizer = [[MotionPinchGestureRecognizer alloc] initWithTarget:self selector:@selector(handlePinchGesture:)];
    pinchRecognizer.numberOfHandsRequired = 2;
    pinchRecognizer.numberOfFingersPerHandRequired = 1;
    pinchRecognizer.possibleDirections = MotionPinchGestureRecognizerDirectionOut | MotionPinchGestureRecognizerDirectionIn;
    [pinchRecognizer startListening];
    
    //Add a non-varaible recognizer as well
    MotionPinchGestureRecognizer *pinchRecognizer2 = [[MotionPinchGestureRecognizer alloc] initWithTarget:self selector:@selector(handlePinchGesture:)];
    pinchRecognizer2.numberOfHandsRequired = 1;
    pinchRecognizer2.numberOfFingersPerHandRequired = 2;
    pinchRecognizer2.possibleDirections = MotionPinchGestureRecognizerDirectionOut | MotionPinchGestureRecognizerDirectionIn;
    [pinchRecognizer2 startListening];
}

-(void)addRotationGesture{
    rotationRecognizer = [[MotionRotationGestureRecognizer alloc] initWithTarget:self selector:@selector(handleRotationGesture:)];
    rotationRecognizer.possibleDirections = MotionRotationGestureRecognizerDirectionClockwise | MotionRotationGestureRecognizerDirectionCounterClockwise;
    rotationRecognizer.numberOfHandsRequired = 1;
    rotationRecognizer.minimumNumberOfFingersRequired = 3;
    [rotationRecognizer startListening];
}

#pragma mark - Handlers

-(void)handlePanGesture:(MotionPanGestureRecognizer *)recognizer{
    if (recognizer.state == MotionGestureRecognizerStateBegan) {
        //Do stuff
    }
    else if (recognizer.state == MotionGestureRecognizerStateChanged){
        //Do stuff
        NSLog(@"Did pan   x:%0.4f    y:%0.4f   z:%0.4f", recognizer.centerpoint.x, recognizer.centerpoint.y, recognizer.centerpoint.z);
    }
    else if (recognizer.state == MotionGestureRecognizerStateEnded){
        
    }
}

-(void)handleSwipeGesture:(MotionSwipeGestureRecognizer *)recognizer{
    if (recognizer.state == MotionGestureRecognizerStateBegan) {
        //Do stuff
    }
    else if (recognizer.state == MotionGestureRecognizerStateChanged){
        //Do stuff
    }
    else if (recognizer.state == MotionGestureRecognizerStateEnded){
        if (recognizer.direction == MotionSwipeGestureRecognizerDirectionLeft) {
            NSLog(@"Did swipe left");
        }
        else if (recognizer.direction == MotionSwipeGestureRecognizerDirectionRight){
            NSLog(@"Did swipe right");
        }
    }
}

-(void)handleTapGesture:(MotionTapGestureRecognizer *)recognizer{
    
    //NSLog(@"Did tap   x:%0.4f    y:%0.4f   z:%0.4f", recognizer.tapVelocity.x, recognizer.tapVelocity.y, recognizer.tapVelocity.z);
    
    if (recognizer.state == MotionGestureRecognizerStateBegan) {
        //Do stuff
    }
    else if (recognizer.state == MotionGestureRecognizerStateChanged){
        //Do stuff
    }
    else if (recognizer.state == MotionGestureRecognizerStateEnded){
        if (recognizer.direction == MotionTapGestureRecognizerDirectionUp) {
            NSLog(@"Did Tap up");
        }
    }
}

-(void)handlePinchGesture:(MotionPinchGestureRecognizer *)recognizer {
    if (recognizer.state == MotionGestureRecognizerStateBegan) {
        //Do stuff
    }
    else if (recognizer.state == MotionGestureRecognizerStateChanged){
        if (recognizer.direction == MotionPinchGestureRecognizerDirectionIn) {
            NSLog(@"Pinching In");
        }
        else if (recognizer.direction == MotionPinchGestureRecognizerDirectionOut){
            NSLog(@"Pinching Out");
        }
    }
    else if (recognizer.state == MotionGestureRecognizerStateEnded){
        
    }
}

-(void)handleRotationGesture:(MotionRotationGestureRecognizer *)recognizer {
    if (recognizer.state == MotionGestureRecognizerStateBegan) {
        //Do stuff
    }
    else if (recognizer.state == MotionGestureRecognizerStateChanged){
        if (recognizer.direction == MotionRotationGestureRecognizerDirectionClockwise) {
            NSLog(@"Rotationg Clockwise");
        }
        else if (recognizer.direction == MotionRotationGestureRecognizerDirectionCounterClockwise){
            NSLog(@"Rotating Counter-Clockwise");
        }
    }
    else if (recognizer.state == MotionGestureRecognizerStateEnded){
        
    }
}

@end
