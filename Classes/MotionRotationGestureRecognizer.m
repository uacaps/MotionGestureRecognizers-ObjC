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

#import "MotionRotationGestureRecognizer.h"

@implementation MotionRotationGestureRecognizer

-(id)initWithTarget:(id)target selector:(SEL)sel{
    if (self == [super init]) {
        //Set callback stuff
        callbackTarget = target;
        callbackSelector = sel;
        self.minimumNumberOfFingersRequired = 3;
        self.possibleDirections = MotionRotationGestureRecognizerDirectionCounterClockwise | MotionRotationGestureRecognizerDirectionClockwise;
        return self;
    }
    
    return self;
}

-(void)positionDidUpdate:(NSArray *)hands{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.hands = hands;
        
        if (hands.count == self.numberOfHandsRequired) {
            if ([self totalFingers] >= self.minimumNumberOfFingersRequired) {
                if ([self isRotating:hands]) {
                    switch (self.state) {
                        case MotionGestureRecognizerStatePossible:
                            //Helps with false positives due to change of direction
                            self.state = MotionGestureRecognizerStateBegan;
                            break;
                        case MotionGestureRecognizerStateBegan:
                            self.state = MotionGestureRecognizerStateChanged;
                            break;
                        case MotionGestureRecognizerStateChanged:
                            self.state = MotionGestureRecognizerStateChanged;
                            break;
                        case MotionGestureRecognizerStateEnded:
                            self.state = MotionGestureRecognizerStateBegan;
                            break;
                        default:
                            break;
                    }
                }
                else {
                    switch (self.state) {
                        case MotionGestureRecognizerStateBegan:
                            if (decelerationCounter > 1) {
                                decelerationCounter = 0;
                                self.state = MotionGestureRecognizerStateEnded;
                            }
                            else {
                                decelerationCounter++;
                            }
                            break;
                        case MotionGestureRecognizerStateChanged:
                            if (decelerationCounter > 1) {
                                decelerationCounter = 0;
                                self.state = MotionGestureRecognizerStateEnded;
                            }
                            else {
                                decelerationCounter++;
                            }
                            break;
                        case MotionGestureRecognizerStateEnded:
                            self.state = MotionGestureRecognizerStatePossible;
                            break;
                        default:
                            break;
                    }
                }
                
                //Call back
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([callbackTarget respondsToSelector:callbackSelector]) {
                        [callbackTarget performSelector:callbackSelector withObject:self];
                    }
                });
            }
        }
    });
}

-(void)resetValues{
    if (self.state == MotionGestureRecognizerStateChanged) {
        self.state = MotionGestureRecognizerStateEnded;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([callbackTarget respondsToSelector:callbackSelector]) {
                [callbackTarget performSelector:callbackSelector withObject:self];
            }
        });
    }
    
    
}

-(BOOL)isRotating:(NSArray *)hands{
    if (hands.count > 0) {
        LeapHand *hand = hands[0];
        LeapVector *newDirection = hand.direction;
        //NSLog(@"x:%f      y:%f      z:%f", newDirection.x, newDirection.y, newDirection.z);
        
        float difference = (100*newDirection.x)-(100*handDirection.x);
        float absoluteDifference = abs(difference);
        
        if (self.possibleDirections & MotionRotationGestureRecognizerDirectionClockwise) {
            
            if (newDirection.x > handDirection.x && absoluteDifference > MOTION_MINIMUM_ROTATION_THRESHOLD) {
                direction = MotionRotationGestureRecognizerDirectionClockwise;
                handDirection = newDirection;
                return YES;
            }
           
        }
        if (self.possibleDirections & MotionRotationGestureRecognizerDirectionCounterClockwise){
            if (newDirection.x < handDirection.x && absoluteDifference > MOTION_MINIMUM_ROTATION_THRESHOLD) {
                direction = MotionRotationGestureRecognizerDirectionCounterClockwise;
                handDirection = newDirection;
                return YES;
            }

            handDirection = newDirection;
        }
    }
    
    return NO;
}

-(MotionRotationGestureRecognizerDirection)direction{
    return direction;
}

-(NSInteger)totalFingers{
    NSInteger total = 0;
    for (LeapHand *hand in self.hands) {
        total += hand.fingers.count;
    }
    
    return total;
}

@end
