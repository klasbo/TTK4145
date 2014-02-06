Exercise 4 : From Prototype to Production
=========================================

1. Don't overengineer.
2. Always design properly.
3. Minor detail change will ruin your perfect model.
4. Always prototype first.
5. You will only know what you didn't know on the second iteration.
6. There is only budget/time for the first version.
7. The prototype will become production.


Exercise
--------

###Create a network module that you can use in the Elevator Project

Take your thoughts from [the beginning of Exercise 1](https://github.com/klasbo/TTK4145/tree/master/Exercise1#1-thinking-about-elevators), and reevaluate them in the light of what you have learned about network programming (and - if applicable - concurrency control).

Here are some things you may want to consider:
 - Will you use TCP, UDP, both, or something completely different?
 - In the case of a master-slave configuration: Do you have only one program, or two?
   - Is a slave becoming a master a part of the network module?
 - If you are using TCP: How do you know who connects to who?
   - Do you need an initialization phase to set up all the connections?
 - Will you be using blocking sockets & many threads, or nonblocking sockets and [`select`](http://en.wikipedia.org/wiki/Select_%28Unix%29)?
 - Do you want to build the necessary reliability into the module, or handle that at a higher level?
 - How will you pack and unpack (serialize) data?
   - Do you use structs, classes, tuples, lists, ...?
   - JSON, XML, or just plain strings?
   - Is serialization a part of the network module?

The key word here is abstraction. This module should simplify the interface between machines: Creating and handling sockets in all routines that need to communicate with the outside world is possible, but unwieldy and unmaintainable. We want to encapsulate all the necessary functionality in a single module, so we have a single decoupled component that can be managed without knowing the workings of the surrounding program. This will almost always be preferable, but above all else: **think about what best suits your design**.
 
Pencil and paper is encouraged! Drawing a diagram/graph of the message pathways will aid in visualizing complexity. Drawing the order of messages through time will let you more easily see what happens when communication fails.


Running from another computer
-----------------------------

You can log in to another computer and run your program remotely. Be nice the people sitting at that computer, and try to avoid using the same ports as them.

 - Logging in:
   - `ssh 129.241.187.###` where ### is the remote IP
 - Copying files from your own machine:
   - `scp -r student@129.241.187.###:fileOrFolderAtYourMachine fileOrFolderAtRemote` where ### is the IP of the machine you are sitting at
    

Extracurricular
---------------

[Things I Wish Someone Had Told Me When I Was Learning How to Code](https://medium.com/learning-to-code/565fc9dcb329)

[21 Nested Callbacks](http://blog.michellebu.com/2013/03/21-nested-callbacks/)