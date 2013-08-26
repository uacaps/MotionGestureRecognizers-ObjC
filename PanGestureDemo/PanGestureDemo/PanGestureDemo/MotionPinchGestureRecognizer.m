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

#import "MotionPinchGestureRecognizer.h"

@implementation MotionPinchGestureRecognizer

-(id)initWithTarget:(id)target selector:(SEL)sel{
    if (self == [super init]) {
        //Set callback stuff
        callbackTarget = target;
        callbackSelector = sel;
        self.possibleDirections = MotionPinchGestureRecognizerDirectionIn | MotionPinchGestureRecognizerDirectionOut;
        return self;
    }
    
    return self;
}

-(void)positionDidUpdate:(NSArray *)hands{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (hands.count == self.numberOfHandsRequired) {
            if ([self isDesiredNumberOfFingers:self.numberOfFingersPerHandRequired perHand:hands]) {
                
                //Do swipe averages
                if ([self isPinching:hands]) {
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

-(BOOL)isPinching:(NSArray *)hands{
    //Get center left point and center right point
    LeapVector *leftPoint = [self leftPinchPointForHands:hands];
    LeapVector *rightPoint = [self rightPinchPointForHands:hands];
    
    if (leftPoint && rightPoint) {
        //Calculate new distance
        float newDistance = [self distanceBetweenLeftPoint:leftPoint rightPoint:rightPoint];
        
        //Check to see if we are properly pinching
        if (self.possibleDirections & MotionPinchGestureRecognizerDirectionIn){
            if (newDistance < distance && abs(newDistance-distance) > MOTION_MINIMUM_PINCH_THRESHOLD) {
                direction = MotionPinchGestureRecognizerDirectionIn;
                distance = newDistance;
                return YES;
            }
        }
        if (self.possibleDirections & MotionPinchGestureRecognizerDirectionOut){
            if (newDistance > distance && abs(newDistance-distance) > MOTION_MINIMUM_PINCH_THRESHOLD) {
                direction = MotionPinchGestureRecognizerDirectionOut;
                distance = newDistance;
                return YES;
            }
        }
    }
    
    return NO;
}

-(LeapVector *)leftPinchPointForHands:(NSArray *)hands{
    if (self.numberOfHandsRequired == 2 && hands.count == 2) {
        return [self avgVectorForHand:hands[0]];
    }
    else {
        if (hands[0]) {
            LeapHand *hand = hands[0];
            if (hand.fingers.count == 2) {
                return [hand.fingers[0] tipPosition];
            }
        }
    }
    
    return nil;
}

-(LeapVector *)rightPinchPointForHands:(NSArray *)hands{
    if (self.numberOfHandsRequired == 2 && hands.count == 2) {
        return [self avgVectorForHand:hands[1]];
    }
    else {
        if (hands[0]) {
            LeapHand *hand = hands[0];
            if (hand.fingers.count == 2) {
                return [hand.fingers[1] tipPosition];
            }
        }
    }
    
    return nil;
}

-(LeapVector *)avgVectorForHand:(LeapHand *)hand{
    float totalXPosition = 0;
    float totalYPosition = 0;
    float totalZPosition = 0;
    
        for (LeapFinger *finger in hand.fingers) {
            
            totalXPosition += finger.tipPosition.x;
            totalYPosition += finger.tipPosition.y;
            totalZPosition += finger.tipPosition.z;
            
        }
    
    //Calculate Averages
    float avgXPos = totalXPosition/hand.fingers.count;
    float avgYPos = totalYPosition/hand.fingers.count;
    float avgZPos = totalZPosition/hand.fingers.count;
    
    //Return Average Vectors
    LeapVector *avgPositionVector = [[LeapVector alloc] initWithX:avgXPos y:avgYPos z:avgZPos];
    return avgPositionVector;
}

-(float)distanceBetweenLeftPoint:(LeapVector *)leftPoint rightPoint:(LeapVector *)rightPoint{
    float dist = sqrtf(powf((leftPoint.x-rightPoint.x), 2) + powf((leftPoint.y -rightPoint.y), 2) + powf((leftPoint.z - rightPoint.z), 2));
    return dist;
}

-(void)resetValues{
    
}

-(MotionPinchGestureRecognizerDirection)direction{
    return direction;
}

@end
