Exercise 7 : 
================

This is the first of a two-part exercise: This time we will look at one way of doing backward error recovery, and next time we will modify this code to use forward error recovery instead. Since we will be needing a rather unique functionality of Ada for our forward error recovery solution, we will be doing both using Ada, to better show the similarities and differences between the two approaches.

###Logistical:
[Intro to Ada](http://www.adaic.org/learn/materials/intro)

[Ada Reference Manual](http://www.adaic.org/resources/add_content/standards/12rm/html/RM-TOC.html)

Compile using `gnatmake`


###Desired functionality:
We are modelling a transaction with three participants, where each performs a calculation that is slow when it works correctly, but fails quickly when it fails. The work from each should not be committed (in this case: printed to the standard output) unless _all_ participants succeed. When any participant fails, the work from all the others will need to be reset, and the transaction has to start over.


###Part 1: Create the transaction work function

The "work" the participants are doing is adding 10 to a number. Unoriginal, perhaps, but we can use random numbers to have it simulate work that either success or fails. We will call this function `Unreliable_Slow_Add`.

 - A random number generator `Gen` is defined and seeded for you. Call `Random(Gen)` to get a random number between 0.0 and 1.0.
 - Most of the time, the addition takes up to 4-ish seconds. Use `delay Duration(d)` (where d is a floating-point number) to pause execution for d seconds. You can use `Random(Gen)` multiplied with a constant as the value for d. Then, add 10 to `x` and return the value.
 - The rest of the time, the operation takes significantly less time (say, up to half a second), but raises an exception instead. A `Count_Failed` exception has been defined for you. (Note: Ada uses `raise`, not `throw`)
 

###Part 2: Do the transaction work

Now that we have the unreliable slow adder, we need to call it, and also catch the exception it throws.

 - The variable we are modifying is called `Num`, and its previous value is called `Prev`.
 - The structure for exception handling in Ada is [begin-exception-end](http://en.wikipedia.org/wiki/Exception_handling_syntax#Ada). There is only one exception to catch: `Count_Failed`. When counting fails, we need to tell the transaction manager that everyone has to revert, by using `Manager.Signal_Abort;` (already implemented).
 - Both in case of success and failure, we need to know what happened to the other participants. The exit protocol lies in the `Finished` entry of the transaction manager, but is not yet implemented (We'll get back to this in part 3). Call it, and trust your future selves that it will be implemented properly.
 - We then ask the manager if we should commit the result. If not, we have to revert to the previous value.

###Part 3: Finish the Manager exit protocol

The exit protocol requires that all participants show up, and all votes are counted. We store the vote using two booleans: `Aborted`, which is set true by the first participant that aborts the transaction (`Signal_Abort`), and `Will_Commit`, which stores this value until the next round starts.

 - The exit protocol needs to function as a "gate", letting participants through only when all of them have arrived. The `Count` attribute holds the number of tasks blocked on the entry condition. No two tasks can run any two entries (or procedures) concurrently. You can use `Finished'Count` as any other integer.
 - When the first participant enters, we open the gate for the other participants. When the last one enters, the gate is closed (for next round).
 - We also need to update and reset the voting variables. When the first participant enters, it can set `Will_Commit`. When the last participant enters, it can reset `Aborted`, since this value is stored in `Will_Commit` until the next round.

 
###Part 4: Run the program

Verify that you get the expected results: All participants either add 10, or all participants revert.


###Questions that will get answers next time (but think about them anyway):

We can have a situation where we have multiple failures in a row, denying any progress from happening. What are the real-time consequences of this?

When one of the participants fails early, all the other participants are doing futile work, and we cannot do anything else until all participants are finished. How can we solve this?












