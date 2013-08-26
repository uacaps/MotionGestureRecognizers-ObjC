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

#import "MotionTapGestureRecognizer.h"
static const float MotionTapDownBeginYThreshold = -300;
static const float MotionTapDownBeginZThreshold = -100;
static const float MotionTapDownBeginZEndThreshold = -80;

@implementation MotionTapGestureRecognizer

-(id)initWithTarget:(id)target selector:(SEL)sel{
    if (self == [super init]) {
        //Set callback stuff
        callbackTarget = target;
        callbackSelector = sel;
        self.possibleDirections = MotionTapGestureRecognizerDirectionDown | MotionTapGestureRecognizerDirectionUp;
        return self;
    }
    
    return self;
}

-(void)positionDidUpdate:(NSArray *)hands{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.hands = [[NSArray alloc] initWithArray:hands];
        
        @autoreleasepool {
            if (hands.count == self.numberOfHandsRequired) {
                if ([self isDesiredNumberOfFingers:self.numberOfFingersPerHandRequired perHand:hands]) {
                    
                    //Get averages
                    MotionAverages *averages = [self averageVectorForHands:hands];
                    
                    //If vectors exist, there is an average of touching points
                    if (averages) {
                        self.tapPoint = averages.positionAverage;
                        self.tapVelocity = averages.velocityAverage;
                        [self processTouchVectors:averages];
                    }
                    else {
                        [self processNonTouch];
                    }
                }
            }
        }
    });
}

-(void)processTouchVectors:(MotionAverages *)averages{
    
    switch (self.state) {
        case MotionGestureRecognizerStatePossible:
            if (averages.velocityAverage.y < MotionTapDownBeginYThreshold && averages.velocityAverage.z < MotionTapDownBeginZThreshold) {
                self.direction = MotionTapGestureRecognizerDirectionDown;
                self.state = MotionGestureRecognizerStateBegan;
            }
            break;
        case MotionGestureRecognizerStateBegan:
            self.state = MotionGestureRecognizerStateChanged;
            if (averages.velocityAverage.y > MotionTapDownBeginYThreshold && averages.velocityAverage.z > MotionTapDownBeginZThreshold) {
                self.direction = MotionTapGestureRecognizerDirectionUp;
            }
            break;
        case MotionGestureRecognizerStateChanged:
            self.state = MotionGestureRecognizerStateChanged;
            
            if (averages.velocityAverage.y > MotionTapDownBeginZThreshold  && averages.velocityAverage.z > MotionTapDownBeginZEndThreshold){
                self.direction = MotionTapGestureRecognizerDirectionUp;
                self.state = MotionGestureRecognizerStateEnded;
            }
            else if (averages.velocityAverage.y > MotionTapDownBeginYThreshold && averages.velocityAverage.z > MotionTapDownBeginZThreshold) {
                self.direction = MotionTapGestureRecognizerDirectionUp;
            }
            break;
        case MotionGestureRecognizerStateEnded:
            self.state = MotionGestureRecognizerStatePossible;
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

-(void)processNonTouch{
    
}

-(void)resetValues{
    
}

@end
