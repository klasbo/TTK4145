Exercise 1 : Hello World
========================

A note about the computers at the real-time lab:
 - They run Linux Mint, Linux Ubuntu and Windows
 - The Ubuntu install is deprecated (it no longer receives security updates), so we reccomend using Mint.
 - Interfacing with the elevator hardware is done using libComedi, which is linux-only. If - for some reason - you want to do the elevator project on Windows, you're on your own.
This exercise does not require that you use the machines at the real-time lab. However, the C code uses POSIX, so you'll need a POSIX-compliant OS, like linux or OSX.

Since we are still in the startup-phase, there are no real groups and assigned lab-times this week (7th to 10th Jan.), which means the workspaces are "first come, first served". Due-date is therefore 17th January.

[Go](http://golang.org) has an [interactive "Tour"](http://tour.golang.org/list) you can take. Its syntax is a bit different, so it may be worth skimming through, or at least using as a quick reference.



1: Thinking about elevators
---------------------------

Not for handing in, just for thinking about.

Brainstorm some techniques you could use to prevent Sverre from being hopelessly stranded.
 - Think about the worst-case behaviour of the system. [http://xkcd.com/748/](http://xkcd.com/748/)
 - Software crashing, communication failing, users being trolls, etc.

 
2: Set up source control and build tools
----------------------------------------

A version control system is a tool helps a group of people work on the same files in a systematic and safe manner, allowing multiple users to make changes to the same file and merge the changes later, and the creation of branches for experimenting with new features in parallel to the main branch. It also keeps track of all versions of files, so that you can revert all changes made since a given date.
You will need some place to store your files, either a decentralized repository online (eg [GitHub](https://github.com/) or [Bitbucket](https://bitbucket.org/) (which also has free private repos)) or centralized on a common group directory at an external server (do not use the machines on the lab for storage, because you never know who might delete it). You can apply for a group directory [here](http://www.stud.ntnu.no/kundesenter/).

 - You can find more info on using the version control console commands here: [Git](http://git-scm.com/), [SVN](http://svnbook.org/), [Mercurial](http://mercurial.selenic.com/)
 - Try [UnGit](https://github.com/FredrikNoren/ungit) as a simpler interface for git. [The video](http://youtu.be/hkBVAi3oKvo) is worth looking at even if you don't plan to use UnGit, since it's a nice explanation of how version control works.

You will probably also want to set up your preferred workflow for coding. Browse through the available text editors and IDEs, and find something that is comfortable to work with. If there is a tool you need that isn't there, tell us.
When you start working on the project, you may also want to set up a build system, either with a makefile or just a shell script. Since the need for this is both language-dependent and IDE-dependent, we won't go into any details here.

 
3: Why concurrency?
-------------------

These things should be google-able:

Why do we use concurrent execution (multithreading/multiprocessing, or the like)? List a fair few reasons.
 - How can adding more concurrent tasks make programming simpler? (Think about translation from idea to code...)
 - And how can it make programming more difficult? (Maybe come back to this after you have worked on part 4 of this exercise)
 
What are the differences between processes, threads, green threads, and fibers?
 - Which one of these do `pthread_create()` (C/POSIX), `threading.Thread()` (Python), `go` (Go) create?
 - How does pythons Global Interpreter Lock (GIL) influence the way a python Thread behaves?
 - With this in mind: What is the workaround for the GIL (Hint: it's another module)? How do you then share resources (variables/data)?
 - What does `func GOMAXPROCS(n int) int` change?
 
(Note: There are other ways of sidestepping the GIL, for example using another interpreter/implementation (IronPython, Jython, Stackless Python, ...))


4: Finally some code
--------------------

Implement this in C, Python and Go:
Look at the "helloworld" examples in this directory (top of this page) for how to create threads.

    main:
        global shared int i = 0
        spawn thread_1
        spawn thread_2
        join all threads
        print i

    thread_1:
        do 1_000_000 times:
            i++
    thread_2:
        do 1_000_000 times:
            i--
            
What happens, and why?


5: One I Prepared Earlier
-------------------------

You will fix the above problem in Exercise 2, so you should save your code for later. If you have started using version control, use this opportunity and start putting it to use.



6: Four Errors
--------------

Run `four_errors.d` with `rdmd four_errors.d` from the command line.
 - What are the four things printed by line 22? ("Error! i is #")
 - Why do we get four things when `i` is only ever set to two different values?
 


