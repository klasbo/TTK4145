Exercise 1 : Hello World
========================

1: Thinking about elevators
---------------------------

Brainstorm some techniques you could use to prevent Sverre from being hopelessly stranded.
 - Think about the worst-case behaviour of the system. [http://xkcd.com/748/](http://xkcd.com/748/)

 
2: Set up source control and build tools
----------------------------------------

A version control system is a tool helps a group of people work on the same files in a systematic and safe manner, allowing multiple users to make changes to the same file and merge the changes later, and the creation of branches for experimenting with new features in parallel to the main branch. It also keeps track of all versions of files, so that you can revert all changes made since a given date.
You will need some place to store your files, either a decentralized repository online (eg [GitHub](https://github.com/) or [Bitbucket](https://bitbucket.org/) (which also has free private repos)) or centralized on a common group directory at an external server (do not use the machines on the lab for storage, because you never know who might delete it). You can apply for a group directory [here](http://www.stud.ntnu.no/kundesenter/).

 - You can find more info on using the version control commands here: [Git](http://git-scm.com/), [SVN](http://svnbook.org/), [Mercurial](http://mercurial.selenic.com/)
 - Try [UnGit](https://github.com/FredrikNoren/ungit) for a simpler interface for git. [The video](http://youtu.be/hkBVAi3oKvo) is worth looking at even if you don't plan to use UnGit, since it's a nice explanation of how version control works

You will probably also want to set up your preferred workflow for coding. Browse through the available text editors and IDEs, and find something that is comfortable to work with. If there is a tool you need that isn't there, tell us.
When you start working on the project, you may also want to set up a build system, either with a makefile or just a shell script. Since the need for this is both language-dependent and IDE-dependent, we won't go into any details here

 
3: Why concurrency?
----------------------

Why do we use concurrent execution (multithreading/multiprocessing, or the like)? List a fair few (3+) reasons.
 - How can adding more concurrent tasks make programming simpler? (Think about translation from idea to code...)
 - And how can it make programming more difficult? (Maybe come back to this after you have worked on part 4 of this exercise)
 
What are the differences between processes, threads, green threads, and fibers?
 - Which one of these do `pthread_create()` (C/POSIX), `threading.Thread()` (Python), `go` (Go) create?
 - How does pythons Global Interpreter Lock influence the way a python Thread behaves?
 - With this in mind: What is the workaround for the GIL (Hint: it's another module)? How do you then share resources (variables/data)?
 - What does `func GOMAXPROCS(n int) int` change?
 
(Note: There are other ways of sidestepping the GIL, for example using another interpreter/implementation (IronPython, Jython, Stackless Python, ...))


4: Finally some code
--------------------

Implement this in C, Python and Go:

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
            
What happens?


5: @property typeof(this) save(){}
----------------------------------

Upload to your repository. You will fix this problem in Exercise 2.


