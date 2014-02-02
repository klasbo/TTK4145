Exercise 5 : Call for transport
===============================

The core C driver [is available here](https://github.com/klasbo/TTK4145/tree/master/Project/driver).

 - `io.c` and `io.h` define the core functions needed to read from and write to the libComedi device
 - `channels.h` gives readable names to the subdevices/channels used with the elevator
 - `elev.c` and `elev.h` show one way of turning `io` and `channels` into a higher level abstraction
 - `main.c` is an incomplete test program to verify the functionality of the `elev` API.


###1:
Interface to the C code, and create a driver for the elevator in the language you are doing the project in.

 - You may want to avoid using the `elev` files:
   - They implement an abstraction you may not agree with.
   - They also define an enum and two arrays, which are not necessarily portable.
   - This means you will also need to convert `channels.h` to the language you are using.
 - Even though the functionality for Stop and Obstruction can be ignored in the project, they should not be ignored here. Include some way of reading both of these.
 - You will need to do polling at some level. Consider if you want to include this as part of the driver.
   - If you include it, you should only notify the "owner" of the driver instance when an event happens (eg a button is pushed, a floor is reached, etc).
   - The owner should preferably state which events it is listening to. Unused events should at least not leak resources.

   
###2:
Write a test program to make sure that the driver works as expected.

 - You should test all the functions you have created.
 - You should test functions with invalid arguments.
 
 
###Bonus:

Optional: Now that you have defined the behaviour of the driver by its functions, you can create a mock elevator that doesn't rely on Comedi or the hardware. With this virtual/simulated elevator, you can test the rest of your program without using the elevator itself, allowing you to work from anywhere.

Only do this if you feel the time spent is worthwhile.