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

#import "MotionSwipeGestureRecognizer.h"
#import "MotionSubscriberCenter.h"
#import "MotionSubscriber.h"


@implementation MotionSwipeGestureRecognizer

-(id)initWithTarget:(id)target selector:(SEL)sel{
    if (self == [super init]) {
        //Set callback stuff
        callbackTarget = target;
        callbackSelector = sel;
        self.minimumSwipeThreshold = 0.8;
        return self;
    }
    
    return self;
}

-(void)positionDidUpdate:(NSArray *)hands{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (hands.count == self.numberOfHandsRequired) {
            if ([self isDesiredNumberOfFingers:self.numberOfFingersPerHandRequired perHand:hands]) {
                MotionAverages *averages = [self averageVectorForHands:hands];
                //NSLog(@"Velocity: %f", averages.velocityAverage.x);
                
                
                //If vector exists, there is an average of touching points
                if (averages) {
                    //Do swipe averages
                    if ([self velocityHighEnough:averages]) {
                        switch (self.state) {
                            case MotionGestureRecognizerStatePossible:
                                //Helps with false positives due to change of direction
                                if (accelerationCounter > 3) {
                                    accelerationCounter = 0;
                                    self.state = MotionGestureRecognizerStateBegan;
                                }
                                else {
                                    accelerationCounter++;
                                }
                                break;
                            case MotionGestureRecognizerStateBegan:
                                self.state = MotionGestureRecognizerStateChanged;
                                break;
                            case MotionGestureRecognizerStateChanged:
                                self.state = MotionGestureRecognizerStateChanged;
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
                else {
                    //[self processNonTouch];
                }
            }
            else {
                [self resetValues];
            }
        }
        else {
            [self resetValues];
        }
    });
    
}

-(void)resetValues{
    decelerationCounter = 0;
    //self.state = MotionGestureRecognizerStatePossible;
    
    if (self.state == MotionGestureRecognizerStateChanged) {
        self.state = MotionGestureRecognizerStateEnded;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([callbackTarget respondsToSelector:callbackSelector]) {
                [callbackTarget performSelector:callbackSelector withObject:self];
            }
            
        });
    }
}

-(BOOL)velocityHighEnough:(MotionAverages *)averages{

    if (self.possibleDirections & MotionSwipeGestureRecognizerDirectionRight) {
        if (averages.velocityAverage.x < -1000*minimumSwipeThreshold) {
            direction = MotionSwipeGestureRecognizerDirectionRight;
            return YES;
        }
    }
    if (self.possibleDirections & MotionSwipeGestureRecognizerDirectionLeft) {
        if (averages.velocityAverage.x > 1000*minimumSwipeThreshold) {
            direction = MotionSwipeGestureRecognizerDirectionLeft;
            return YES;
        }
    }
    if (self.possibleDirections & MotionSwipeGestureRecognizerDirectionDown) {
        if (averages.velocityAverage.y < -1000*minimumSwipeThreshold) {
            direction = MotionSwipeGestureRecognizerDirectionDown;
            return YES;
        }
    }
    if (self.possibleDirections & MotionSwipeGestureRecognizerDirectionUp) {
        if (averages.velocityAverage.y > 1000*minimumSwipeThreshold) {
            direction = MotionSwipeGestureRecognizerDirectionUp;
            return YES;
        }
    }
    if (self.possibleDirections & MotionSwipeGestureRecognizerDirectionIn) {
        if (averages.velocityAverage.z < -1000*minimumSwipeThreshold) {
            direction = MotionSwipeGestureRecognizerDirectionIn;
            return YES;
        }
    }
    if (self.possibleDirections & MotionSwipeGestureRecognizerDirectionDown) {
        if (averages.velocityAverage.z > 1000*minimumSwipeThreshold) {
            direction = MotionSwipeGestureRecognizerDirectionDown;
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Setters/Getters

-(void)setMinimumSwipeThreshold:(float)newThreshold{
    if (newThreshold > 1) {
        minimumSwipeThreshold = 1;
    }
    else if (newThreshold < 0){
        minimumSwipeThreshold = 0;
    }
    else{
        minimumSwipeThreshold = newThreshold;
    }
}

-(MotionSwipeGestureRecognizerDirection)direction{
    return direction;
}

@end
