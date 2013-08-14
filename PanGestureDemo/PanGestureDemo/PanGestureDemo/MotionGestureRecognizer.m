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

#import "MotionGestureRecognizer.h"
#import "MotionSubscriber.h"
#import "LeapSubscriber.h"


@implementation MotionGestureRecognizer

-(u_int32_t)randomIdentifier{
    return arc4random()%UINT_FAST32_MAX;
}

-(CGPoint)locationOfVector:(LeapVector *)leapVector inWindow:(NSWindow *)window scaler:(float)scaler{
    //NSLog(@"yCoord: %f", leapVector.y);
    
    float XScale = window.frame.size.width/MOTION_X_DOMAIN;
    float YScale = window.frame.size.height/MOTION_Y_DOMAIN;
    
    //Calculate scaled X value
    float xPosition = 0;
    if (leapVector.x <= 0) {
        if (leapVector.x*scaler < MOTION_X_MINIMUM) {
            xPosition = leapVector.x*scaler - MOTION_X_MINIMUM;
        }
        else {
            xPosition = (float)abs(MOTION_X_MINIMUM - leapVector.x*scaler);
        }
    }
    else {
        xPosition = leapVector.x*2 + MOTION_X_DOMAIN/2;
    }
    
    //Calculate scaled Y value
    float yPosition = 0;
    yPosition = leapVector.y;
    
    float yMidpoint = MOTION_Y_DOMAIN/2;
    float yDifference = yPosition - (yMidpoint); //+ or - version
    
    yDifference = yDifference*scaler;
    float newY = yDifference + MOTION_Y_DOMAIN/2;

    //Calculate window scaled X and Y
    float windowScaledX = xPosition*XScale;
    float windowScaledY = newY*YScale;

    return CGPointMake(windowScaledX, windowScaledY);
}

-(BOOL)isDesiredNumberOfFingers:(NSUInteger)numberOfFingers perHand:(NSArray *)hands{
    
    for (LeapHand *hand in hands) {
        @autoreleasepool {
            if (hand.fingers.count != numberOfFingers) {
                return NO;
            }
        }
    
    }
    
    return YES;
}

-(MotionAverages *)averageVectorForHands:(NSArray *)handsArray{
    float totalXPosition = 0;
    float totalYPosition = 0;
    float totalZPosition = 0;
    
    float totalXVelocity = 0;
    float totalYVelocity = 0;
    float totalZVelocity = 0;
    
    NSInteger totalNumberOfFingers = 0;
    
    //Collect Totals
    
    for (LeapHand *hand in handsArray) {
        
        for (LeapFinger *finger in hand.fingers) {
            @autoreleasepool {
                totalNumberOfFingers += 1;
            
                totalXPosition += finger.tipPosition.x;
                totalYPosition += finger.tipPosition.y;
                totalZPosition += finger.tipPosition.z;
            
                totalXVelocity += finger.tipVelocity.x;
                totalYVelocity += finger.tipVelocity.y;
                totalZVelocity += finger.tipVelocity.z;
                }
        }
        
    }
    
    
    //Calculate Averages
    float avgXPos = totalXPosition/totalNumberOfFingers;
    float avgYPos = totalYPosition/totalNumberOfFingers;
    float avgZPos = totalZPosition/totalNumberOfFingers;
    
    float avgXVel = totalXVelocity/totalNumberOfFingers;
    float avgYVel = totalYVelocity/totalNumberOfFingers;
    float avgZVel = totalZVelocity/totalNumberOfFingers;
    
    //Return Average Vectors
    LeapVector *avgPositionVector = [[LeapVector alloc] initWithX:avgXPos y:avgYPos z:avgZPos];
    LeapVector *avgVelocityVector = [[LeapVector alloc] initWithX:avgXVel y:avgYVel z:avgZVel];
    
    MotionAverages *averages = [[MotionAverages alloc] initWithPosition:avgPositionVector velocity:avgVelocityVector];
    return averages;
}

-(void)startListening{
    //Create Subscriber
    if (!identifier){
        MotionSubscriber *subscriber = [[MotionSubscriber alloc] initWithTarget:self selector:@selector(positionDidUpdate:) identifier:[self randomIdentifier]];
        identifier = subscriber.identifier;
        
        //Add Subscriber
        [[LeapSubscriber sharedSubscriber] addSubscriber:subscriber];
    }
    else {
        [[LeapSubscriber sharedSubscriber] activateSubscriber:identifier];
    }
    
    
    [[LeapSubscriber sharedSubscriber] startListening];
}

-(void)stopListening{
    [[LeapSubscriber sharedSubscriber] removeSubscriber:identifier];
}

@end
