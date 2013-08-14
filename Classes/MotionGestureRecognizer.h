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

#import <Foundation/Foundation.h>
#import "LeapObjectiveC.h"
#import "MotionAverages.h"

#define MOTION_X_DOMAIN 900
#define MOTION_X_MINIMUM -450
#define MOTION_X_MAXIMUM 450
#define MOTION_Y_DOMAIN 500
#define MOTION_Y_MINIMUM 100
#define MOTION_Y_MAXIMUM 600
#define MOTION_Z_DOMAIN 700
#define MOTION_Z_MINIMUM -350
#define MOTION_Z_MAXIMUM 350

#define MOTION_MINIMUM_PINCH_THRESHOLD 0.01
#define MOTION_MINIMUM_ROTATION_THRESHOLD 0.01


typedef enum {
    MotionGestureRecognizerStatePossible,
    
    MotionGestureRecognizerStateBegan,
    MotionGestureRecognizerStateChanged,
    MotionGestureRecognizerStateEnded,
    MotionGestureRecognizerStateCancelled,
    
    MotionGestureRecognizerStateFailed,
    
    MotionGestureRecognizerStateRecognized = MotionGestureRecognizerStateEnded
} MotionGestureRecognizerState;

@interface MotionGestureRecognizer : NSObject {
    __strong id callbackTarget;
    SEL callbackSelector;
    
    u_int32_t identifier;
}

@property(nonatomic, assign) MotionGestureRecognizerState state;
@property (atomic, retain) NSArray *hands;
@property (nonatomic, assign) NSUInteger numberOfFingersPerHandRequired;
@property (nonatomic, assign) NSUInteger numberOfHandsRequired;
@property(nonatomic, getter=isEnabled) BOOL enabled;

-(u_int32_t)randomIdentifier;

-(CGPoint)locationOfVector:(LeapVector *)leapVector inWindow:(NSWindow *)window scaler:(float)scaler;

//Internal Helpers
-(BOOL)isDesiredNumberOfFingers:(NSUInteger)numberOfFingers perHand:(NSArray *)hands;
-(MotionAverages *)averageVectorForHands:(NSArray *)handsArray;

-(void)startListening;
-(void)stopListening;

@end
