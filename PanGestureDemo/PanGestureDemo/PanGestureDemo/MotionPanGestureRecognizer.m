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

#import "MotionPanGestureRecognizer.h"
#import "MotionSubscriberCenter.h"

@implementation MotionPanGestureRecognizer

-(id)initWithTarget:(id)target selector:(SEL)sel{
    if (self == [super init]) {
        //Set callback stuff
        callbackTarget = target;
        callbackSelector = sel;
        
        return self;
    }
    
    return self;
}

-(void)positionDidUpdate:(NSArray *)hands{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.hands = [[NSArray alloc] initWithArray:hands];
        
        if (hands.count == self.numberOfHandsRequired) {
            if ([self isDesiredNumberOfFingers:self.numberOfFingersPerHandRequired perHand:hands]) {
                LeapVector *vector = [self averageVectorForHands:hands].positionAverage;
                
                //If vector exists, there is an average of touching points
                if (vector) {
                    self.centerpoint = vector;
                    [self processTouchVector:vector];
                }
                else {
                    [self processNonTouch];
                }
            }
        }
    });
}

-(void)processTouchVector:(LeapVector *)vector{
    switch (self.state) {
        case MotionGestureRecognizerStateBegan:
            self.state = MotionGestureRecognizerStateChanged;
            break;
        case MotionGestureRecognizerStateChanged:
            self.state = MotionGestureRecognizerStateChanged;
            break;
        case MotionGestureRecognizerStateEnded:
            self.state = MotionGestureRecognizerStateBegan;
            break;
        case MotionGestureRecognizerStatePossible:
            self.state = MotionGestureRecognizerStateBegan;
            break;
        default:
            break;
    }
    
    //Call back
    dispatch_async(dispatch_get_main_queue(), ^{
         @autoreleasepool {
             if ([callbackTarget respondsToSelector:callbackSelector]) {
                 [callbackTarget performSelector:callbackSelector withObject:self];
             }
         }
    });
}

-(void)processNonTouch {
    if (self.state == MotionGestureRecognizerStateEnded) {
        self.state = MotionGestureRecognizerStatePossible;
    }
    else if (self.state == MotionGestureRecognizerStateChanged){
        self.state = MotionGestureRecognizerStateEnded;
    }
}

-(void)resetValues{
    self.state =MotionGestureRecognizerStatePossible;
}
@end
