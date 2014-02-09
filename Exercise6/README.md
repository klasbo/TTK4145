Exercise 6 : Phoenix
====================

####1: Process pairs
Create a program (in any language) that uses the _process pair_ technique to print the numbers `1`, `2`, `3`, etc to a terminal window. The program should create its own backup: When the primary is running, _only the primary_ should keep counting, and the backup should do nothing. When the primary dies, the backup should become the new primary, create its own new backup, and keep counting where the dead one left off. Make sure that no numbers are skipped!

You cannot rely on the primary telling the backup when it has died (because it would have to be dead first...). Instead, have the primary broadcast that it is alive a few times a second, and have the backup become the primary when a certain number of messages have been missed.

You will need some form of communication between the primary and the backup. Some examples are:
 - Network: The simplest is to use UDP on localhost. TCP is also possible, but may be harder (since both endpoints need to be alive).
 - IPC, such as POSIX message queues: see [`msgget()` `msgsnd()` and `msgrcv()`](http://pubs.opengroup.org/onlinepubs/7990989775/xsh/sysmsg.h.html). With these you can create FIFO message queues.
 - [Signals](http://pubs.opengroup.org/onlinepubs/7990989775/xsh/signal.h.html): Use signals to interrupt other processes (You are already familiar with some of these, such as SIGSEGV (Segfault) and SIGTERM (Ctrl+C)). There are two custom signals you can use: SIGUSR1 and SIGUSR2. See `signal()`.
   - Note for D programmers: [SIGUSR is used by the GC.](http://dlang.org/phobos/core_memory.html)
 - Files: The primary writes to a file, and the backup reads it. Either the time-stamp of the file or the contents can be used to detect if the primary is still alive.
   - Note for the project: You should really use reliable reads and writes here. Perhaps your distributed storage could be the other elevators?
 - Controlled shared memory: The system functions [`shmget()` and `shmat()`](http://pubs.opengroup.org/onlinepubs/7990989775/xsh/sysshm.h.html) let processes share memory.

You will also need to spawn the backup somehow. There should be a way to spawn processes or run shell commands in the standard library of your language of choice.

Be careful! You don't want to create a [chain reaction...](http://en.wikipedia.org/wiki/Fork_bomb)

(Note for the project: Usually a program crashes for a reason. Restoring the program to the same state as it died in may cause it to crash in exactly the same way, all over again.)
 
####2: Guarantees (Optional)
Make your program print each number once and _only_ once, and demonstrate (a priori, not just through observation of your program) that it will behave this way, regardless of when the primary is killed.