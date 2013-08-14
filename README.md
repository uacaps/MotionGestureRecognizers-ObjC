Motion Gestures for Objective-C
=============

This is a drop-in wrapper on top of the classes for interacting with a Leap Motion - it allows for the handling of gesture recognition similar to what you would find in the world of iOS: simple listeners and events abstracted as high as they can go.

Some things you'll need:
* Leap Motion device
* Download the [Leap Motion SDK](https://developer.leapmotion.com/downloads) to get the required classes (more on that in a second)

**Also Available for Windows**

The Motion Gesture Recognizer libraries are also available in C# for Windows here: https://github.com/uacaps/MotionGestureRecognizers-CSharp

--------------------
## Set-Up ##

**Installing the Leap libraries and classes**

Begin by starting a new Xcode project and choose Cocoa application. Open the folder with the Leap SDK unbundled inside it then open the subdirectory LeapSDK. Follow these steps to get up and running:

* Drag <code>/lib/libLeap.dylib</code> into your project. It will show up in the *Link Binary With Libraries* section
* Click the name of your new project, and you will be greeted with a screen that has Summary, Info, Build Settings, etc.
* Make sure the Target is selected and not the project, click the plus button at the bottom of the screen labeled *Add Build Phase*
* A new section named Copy Files is available. Select *Executables* in the Destination drop-down menu under that section.
* Click the plus in that section, and add libLeap.dylib in there as well.
* Click the name of your project under the Project heading, and navigate to *Build Settings*
* Navigate to the subsection labeled <code>Apple LLVM compiler 4.2 - Language</code>.
* In that section, there is a key titled C++ Standard Library - select <code>libstdc++ (GNU C++ standard library)</code>

![ScreenShot](https://raw.github.com/uacaps/MotionGestureRecognizers-ObjC/master/Screenshots/screen1.png)

![ScreenShot](https://raw.github.com/uacaps/MotionGestureRecognizers-ObjC/master/Screenshots/screen2.png)

Now that those initial steps are complete, go back to your Finder and the open LeapSDK folder. Open the <code>include</code> directory in there and drag the following files into your project:

* Leap.h
* LeapMath.h
* LeapObjectiveC.h
* LeapObjectiveC.mm

Once you have done these steps, build and make sure your project has no errors. Good? Let's move on.

Now that you've got the Leap Motion SDK's files in your project, you can add the **Motion Gesture Recognizer** classes in as well. Start off by dragging every file in the **Classes** top-level directory of the repository into your project. This includes the following files:

* MotionAverages.{h,m}
* MotionGestureRecognizer.{h,m}
* MotionGestures.h
* MotionPanGestureRecognizer.{h,m}
* MotionPinchGestureRecognizer.{h,m}
* MotionRotationGestureRecognizer.{h,m}
* MotionSubscriber.{h,m}
* MotionSubscriberCenter.{h,m}
* MotionSwipeGestureRecognizer.{h,m}
* MotionTapGestureRecognizer.{h,m}
* LeapCore.{h,m}

To begin using the different recognizers in your classes just <code>#import "MotionGestures.h"</code> into the Header file. This is just the top-level file that imports everything you'll need. That's all you have to do to get ready, but build and make sure that the project doesn't have any errors before you go forward.

--------------------
## Using a Motion Gesture Recognizer ##

```objc
- (void)createPanGestureRecognizer {
	MotionPanGestureRecognizer *panRecognizer = [[MotionPanGestureRecognizer alloc] initWithTarget:self selector:@selector(handlePanGesture:)];
	panRecognizer.numberOfFingersPerHandRequired = 1;
    panRecognizer.numberOfHandsRequired = 1;
    [panRecognizer startListening];
}
```

As you can tell, setting up a gesture recognizer is not a difficult operation. Let's walk through it. In the first line, you allocate and initialize the MotionPanGestureRecognizer - setting the target to self (though you could set it on another NSObject just as easily) and passing in the handler method as a @selector. More on handling in just a second. After doing that we set the number of fingers and number of hands required to activate, and that it's listening for. This means that you could have a pan gesture that uses two fingers and one that uses one finger without causing any funky overlaps or having to use one method to handle both. Finally we start listening for the gesture. Now for a method on handling the gesture and its various states:

```objc
- (void)handlePanGesture:(MotionPanGestureRecognizer *)recognizer {
	if (recognizer.state == MotionGestureRecognizerStateBegan) {
        // When the gesture begins
    }
    else if (recognizer.state == MotionGestureRecognizerStateChanged) {
        // After the gesture has begun, and its state is in flux.
    }
    else if (recognizer.state == MotionGestureRecognizerStateEnded) {
        // When the gesture has ended
    }
    else if (recognizer.state == MotionGestureRecognizerStatePossible) {
        // When the gesture recognizer is in a state of readiness - it can accept gestures
    }
}
```

In the handling method, we are checking for various states that the recognizer can be in. These can be used in different ways for the type of gesture recognizing you are doing. For instance, you could use a pan recognizer that grabs the CGPoint of where your finger is - then draw something on screen or use for "clicks" during <code>MotionGestureRecognizerStateChanged</code>. However, if you wanted a swipe gesture, you may handle it when <code>recognizer.state == MotionGestureRecognizerStateEnded</code>, allowing you to check the direction of the swipe and go from there.

--------------------
## Types of Motion Gesture Recognizers ##

Each gesture recognizer requires a number of hands and a number of fingers to account for when listening for motion events. MotionRotationGestureRecognizer is one that requires a *minimum* number of fingers because of the way Leap counts digits based on palm location. Your fingers might be aligned vertically resulting in the system thinking it's 1 finger, and as you rotate, more will be recognized.

Each gesture recognizer also has a method at your disposal to find location of digits in view (this will find the center point of your fingers). The scalar in this method, is basically like mouse sensitiviy - a value of 2 or 3 is about the baseline. However if it is moving too fast or too slow, edit this accordingly. A good example of how to use this method is in the **PanGestureDemo** Xcode project included in the repository. You can call this method like so:

```objc
CGPoint *centerPoint = [recognizer locationOfVector:recognizer.centerpoint
										   inWindow:self.window
										     scalar:2];
```

The various types of Motion Gesture recognizers and how they work is listed below.

**MotionPanGestureRecognizer**

The MotionPanGestureRecognizer handles panning and is akin to dragging your finger around in free-space.

**MotionSwipeGestureRecognizer**

This gesture handles swipes that are quick, hard motions in a single vector (up,down,left,right).

**MotionPinchGestureRecognizer**

This gesture handles fingers getting closer or further away from each other, ala pinching your nose.

**MotionRotationGestureRecognizer**

This gesture is similar to opening a doorknob (reveals clockwise and counterclockwise rotation).

**MotionTapGestureRecognizer**

This gesture is like poking an imaginary button in front of the screen.

--------------------
## Demos ##

To see the Motion Gesture Recognizer in action, we have included a few demo Mac OS X projects for your sampling. Due to Leap's software agreement, we can't include their necessary classes directly in the projects we open source. So, to use the demo, go to the **Setup** section at the top of the README, then follow along for adding Leap's specific files and their various installation settings. Once that's done you will be able to build and run the projects - and follow along with what we did in code.

--------------------

## License ##

Copyright (c) 2012 The Board of Trustees of The University of Alabama
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. Neither the name of the University nor the names of the contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.
