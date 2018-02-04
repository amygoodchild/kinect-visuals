# kinect-visuals
Exploring visuals/body representations using Processing and skeleton tracking with a Kinect v2.

Requires the Kinect SDK to be installed, as well as the Kinect PV2 library and OSCP5 libraries for Processing.

## Send Skeleton 

The SendSkeleton file is heavily based on KinectPV2 Library Examples by Thomas Sanchez Lengeling - http://codigogenerativo.com/.

It takes the skeleton data from a KinectPV2 and sends it over OSC.

It can be used in combination with any of the other files, which receive the OSC messages and use them to draw shapes etc.

Drawing in the same sketch as the Kinect library seemed to cause conflicts with perspective, measurements, distances etc which makes it laborious to draw animations, requiring lots of transforms and slowing framerate. Probably a problem that is solveable in another way but this solution works. Also means that the SendSkeleton sketch can be used to send Kinect data to Openframeworks, which doesn't seem to jive with my Kinect at all.


## Get Skeleton - Weird Bodies

![Example of weird bodies Kinect sketch](https://github.com/amygoodchild/kinect-visuals/blob/master/Example%20Images/weirdbodies.PNG)

[See a video of this sketch on Instagram](https://www.instagram.com/p/BeWJS-Cg9xX/)

Draws some weird little bodies by joining up skeleton points "wrongly".
Easy to make new designs, just look up the numbers for the skeleton joints you want to use. (Google kinect skeleton joints - the numbers are standardised)

## Get Skeleton - Kaleidoscope

![Example of kaleidoscope Kinect sketch](https://github.com/amygoodchild/kinect-visuals/blob/master/Example%20Images/kaleidoscope.PNG)

[See an example of (an earlier version of) this sketch on Youtube](https://www.youtube.com/watch?v=z4lCLuj5lGU)

Draws curvy kaleidoscopey shapes based on the tracked skeleton. Reacts to beats in music. 
