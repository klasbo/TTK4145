Elevator Project
================

![](https://raw.github.com/klasbo/TTK4145/master/Project/ElevatorHardware.jpg)


Summary
-------
Create software for controlling n elevators working in parallel across m floors.


Main requirements
-----------------
Be reasonable: There are surely many semantic hoops that you can jump through to create something that is "technically correct". Contact us if you feel that something is clearly ambiguous or missing from these requirements.

No orders are lost
 - Once the light on an external button (calling an elevator to that floor; top 6 buttons on the control panel) is turned on, an elevator should arrive at that floor
 - Similarly for an internal button (telling the elevator what floor you want to exit at; front 4 buttons on the control panel), but only the elevator at that specific workspace should take the order
 - If the elevator is disconnected from the network, it should still serve whatever orders are currently "in the system" (ie whatever lights are showing)
   - It should also serve the internal orders, so that people can exit the elevator even if it is disconnected

Multiple elevators should be more efficient than one
 - Distribute the orders across the elevators in a reasonable way
 - You are free to choose and design your own "cost function" of some sort: Minimal movement, minimal waiting time, etc.
 
An individual elevator should behave sensibly and efficiently
 - No stopping at every floor "just to be safe"
 - The external "call upward" and "call downward" buttons should behave differently
   - Eg if the elevator is moving from floor 1 up to floor 4 and there is a downward order at floor 3, then the elevator should not stop on its way upward
 
The lights should function as expected
 - The lights on the external buttons should show the same thing on all n workspaces
 - The internal lights should not be shared between elevators
 - The "door open" lamp should be used as a substitute for an actual door, and as such should not be switched on while the elevator is moving

 
Start with 1 <= n <= 3 elevators, and m == 4 floors. Try to avoid hard-coding these values: You should be able to add a fourth elevator with no extra configuration, or change the number of floors with minimal configuration. You do, however, not need to test for n > 3 and m != 4.

Unspecified behaviour
---------------------
Some things are left intentionally unspecified. Their implementation will not be explicitly tested, and are therefore up to you.

Which orders are cleared when stopping at a floor
 - You can clear only the orders in the direction of travel, or assume that everyone enters/exits the elevator when the door opens
 
How the elevator behaves when it cannot connect to the network during initialization
 - You can either enter a "single-elevator" mode, or refuse to start
 
How the external (call up, call down) buttons work when the elevator is disconnected from the network
 - You can optionally refuse to take these new orders
 

Simplifications
---------------
Try to create something that works at a base level first, before adding more advanced features. You are of course free to include any or all (or more) of these optional features from the start.

You can make these simplifications and still get full score:
 - At least one elevator is always alive
 - Stop button & Obstruction switch are disabled
   - Their functionality (if/when implemented) is up to you.
 - No multiple simultatneous errors: Only one error happens at a time, but the system must still return to a fail-safe state after this error
 - No network partitioning: A situation where there are multiple sets of two or more elevators with no connection between them
   
   

Evaluation
----------
Dates to be decided.

 - Completion
   - The elevator system works in accordance to the main specification
   - The student assistants will use a checklist of various scenarios to evaluate this
 - Design
   - The system is robust: It is always in a fail-safe state where no orders are lost
   - You will create a short presentation about your fault tolerance strategies (More details to come)
 - Code Review
   - Code quality: Well written, structured, easy to navigate, consistent, etc.
   - Idiomatic wrt. the language (Using the language the way it is supposed to be used)
   - Maintainability: Separated into modules, APIs are complete, easy to swap out pieces of code
   - Ease of adding features you simplified away (if any)
   - Demonstrate understanding of your own code
   - (More details to come)
   
   
   
Language resources
------------------
We encourage submissions to this list! Tutorials, libraries, articles, blog posts, talks, videos...

 - [Python](http://python.org/)
   - [Official tutorial (2.7)](http://docs.python.org/2.7/tutorial/)
   - [Python for Programmers](https://wiki.python.org/moin/BeginnersGuide/Programmers) (Several websites/books/tutorials)
   - [Advanced Python Programming](http://www.slideshare.net/vishnukraj/advanced-python-programming)
   - [Socket Programming HOWTO](http://docs.python.org/2/howto/sockets.html)
 - C
   - [Amended C99 standard](http://www.open-std.org/jtc1/sc22/wg14/www/docs/n1256.pdf) (pdf)
   - [GNU C library](http://www.gnu.org/software/libc/manual/html_node/)
   - [POSIX '97 standard headers index](http://pubs.opengroup.org/onlinepubs/7990989775/headix.html)
   - [POSIX.1-2008 standard](http://pubs.opengroup.org/onlinepubs/9699919799/) (Unnavigable terrible website)
   - [Beej's network tutorial](http://beej.us/guide/bgnet/)
   - [Deep C](http://www.slideshare.net/olvemaudal/deep-c)
 - [Go](http://golang.org/)
   - [Official tour](http://tour.golang.org/)
   - [Go by Example](https://gobyexample.com/)
   - [Learning Go](http://www.miek.nl/projects/learninggo/)
   - From [the wiki](http://code.google.com/p/go-wiki/): [Articles](https://code.google.com/p/go-wiki/wiki/Articles), [Talks](https://code.google.com/p/go-wiki/wiki/GoTalks)
   - [Advanced Go Concurrency Patterns](https://www.youtube.com/watch?v=QDDwwePbDtw) (video): transforming problems into the for-select-loop form
 - [D](http://dlang.org/)
   - [The book](http://www.amazon.com/exec/obidos/ASIN/0321635361/) by Andrei Alexandrescu ([Chapter 1](http://www.informit.com/articles/article.aspx?p=1381876), [Chapter 13](http://www.informit.com/articles/article.aspx?p=1609144))
   - [Programming in D](http://ddili.org/ders/d.en/)
   - [Pragmatic D Tutorial](http://qznc.github.io/d-tut/)
   - [DConf talks](http://www.youtube.com/channel/UCzYzlIaxNosNLAueoQaQYXw/videos)
   - [Vibe.d](http://vibed.org/)
 - [Erlang](http://www.erlang.org/)
   - [Learn you some Erlang for great good!](http://learnyousomeerlang.com/content)
   - [Erlang: The Movie](http://www.youtube.com/watch?v=uKfKtXYLG78), [Erlang: The Movie II: The sequel](http://www.youtube.com/watch?v=rRbY3TMUcgQ)
 - [Rust](http://www.rust-lang.org/)
 - Java
   - [The Java Tutorials](http://docs.oracle.com/javase/tutorial/index.html)
   - [Java 7 API spec](http://docs.oracle.com/javase/7/docs/api/)
 - [Scala](http://scala-lang.org/)
   - [Learn](http://scala-lang.org/documentation/)

<!-- -->
 
 - Design and code quality
   - [The State of Sock Tubes](http://james-iry.blogspot.no/2009/04/state-of-sock-tubes.html): How "state" is pervasive even in message-passing- and functional languages
   - [Defactoring](http://raganwald.com/2013/10/08/defactoring.html): Removing flexibility to better express intent
   - [The Future of Programming](http://vimeo.com/71278954) (video): A presentation on what programming may look like 40 years from now... as if it was presented 40 years ago.
   - [http://www.slideshare.net/ScottWlaschin/railway-oriented-programming](Railway Oriented Programming): A functional approach to error handling
   - [https://www.youtube.com/watch?v=i_oA5ZWLhQc](Practical Unit Testing) (video): "Readable, Maintainable, and Trustworthy"
   - [https://www.youtube.com/watch?v=3G-LO9T3D1M&t=4h31m25s](Core Principles and Practices for Creating Lightweight Design) (video)
   
Other
-----
You are encouraged to exchange ideas with your fellow students. Or, to put it another way: You are required to exchange ideas with your fellow students.

**Be gentle with the hardware.** The buttons aren't designed for bashing. Sliding the "elevator" up and down is fine. Make sure no cables are dangling behind and under the workspace.


Drivers
-------
Are found in the directory called [driver](driver)


Contact
-------
Any questions or suggestions to this text/the project in general?

Send an email, a message on It's Learning, open an issue, or create a pull request.







