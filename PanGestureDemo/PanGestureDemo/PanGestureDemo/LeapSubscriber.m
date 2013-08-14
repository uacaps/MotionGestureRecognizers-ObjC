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

#import "LeapSubscriber.h"
#import "LeapCore.h"

@implementation LeapSubscriber
static LeapSubscriber* _sharedSubscriber = nil;

+(LeapSubscriber*)sharedSubscriber
{
	@synchronized([LeapSubscriber class])
	{
		if (!_sharedSubscriber)
            _sharedSubscriber  = [[LeapSubscriber alloc]init];
		
		return _sharedSubscriber;
	}
	
	return nil;
}

+(id)alloc
{
	@synchronized([LeapSubscriber class])
	{
		NSAssert(_sharedSubscriber == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedSubscriber = [super alloc];
		return _sharedSubscriber;
	}
	
	return nil;
}

-(id)init {
	self = [super init];
	if (self != nil) {
        self.subscribers = [NSMutableArray array];
	}
	
	return self;
}

-(void)startListening{
    if (!isListening) {
        isListening = YES;
        
        leapCore = [[LeapCore alloc]init];
        leapCore.delegate = self;
        [leapCore run];
    }
}

#pragma mark - Leap Core Delegate

-(void)positionDidUpdateWithHands:(NSArray *)hands{
    //Proliferate updates!
    [self.subscribers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (((MotionSubscriber *)obj).active) {
            [((MotionSubscriber *)obj).target performSelector:((MotionSubscriber *)obj).selector withObject:hands];
        }
    }];
}

-(void)noHandsFound{
    [self.subscribers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [((MotionSubscriber *)obj).target performSelector:@selector(resetValues) withObject:nil];
    }];
}

#pragma mark - Subscribers

-(void)addSubscriber:(MotionSubscriber *)subscriber{
    subscriber.active = YES;
    [self.subscribers addObject:subscriber];
}

-(void)removeSubscriber:(u_int32_t)identifier{
    [self.subscribers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (((MotionSubscriber *)obj).identifier == identifier) {
            ((MotionSubscriber *)obj).active = NO;
            return;
        }
    }];
}

-(void)activateSubscriber:(u_int32_t)identifier{
    [self.subscribers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (((MotionSubscriber *)obj).identifier == identifier) {
            ((MotionSubscriber *)obj).active = YES;
            return;
        }
    }];
}

@end
