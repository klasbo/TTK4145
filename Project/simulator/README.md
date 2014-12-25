What is it
==========

An extension to `io.c` that lets you choose between a "hardware" elevator (the normal libcomedi interface) and a simulated one.


Files
=====

 - `simulator_interface`: A program that communicates (over UDP localhost) with the simulated elevator, such that it can display the state of the elevator and take input (from keyboard) to simulate buttons and switches
 - `simulation_elevator.a`: The simulated elevator, pre-built to a library such that it can be linked like any other object file
 - `libphobos2.a`: D standard library v2.066.1, required by `simulation_elevator.a`
 - `simulator.con`: A config file for the simulation


Usage
=====

API changes
-----------
The only difference is:
 - `io_init(ElevatorType type)`
 - Takes either `ET_comedi` or `ET_simuation`

Linking
-------
Give your linker of choice `simulation_elevator.a` and `libphobos2.a` like any other object files.
 - Eg: `gcc [compile options] [c-files] simulation_elevator.a libphobos2.a -lpthread -lcomedi -lm`
 
Running
-------
The simulator interface is a standalone program, and is intended to run in its own window. It communicates over UDP localhost, so it does not need to be restarted even if the "Elevator" is restarted.  

The simulated elevator is spawned by calling `io_init(ElevatorType)` with `ET_simulation`.
 
Keyboard controls
-----------------
QWE, SDF, and ZXCV control the Up, Down and Command buttons.  
T controls the stop button, G toggles the obstruction switch.  
(A keypress must be followed by pressing Enter.)  

The duration of a keypress is set in `simulator.con`.

Display
-------
The ascii-art-style display is updated whenever the state of the simulated elevator is updated.

A print count (number of times a new state is printed) is shown in the lower right corner of the display. Try to avoid writing to the (simulated) hardware if nothing has happened, as writing to the screen is painfully slow. A jump of 20-50 in the printcount is fine (even expected), but if there are larger jumps or there is a continous upward count, it is time to re-evaluate some design choices.


Building from source
====================

The simulated elevator and the elevator interface are written in D. To build from source:
 - `simulator_interface`: `dmd simulator_interface.d`
 - `simulation_elevator.a`: `dmd simulation_elevator.d timer_event.d -lib -ofsimulation_elevator`
 
Useful dmd flags:
 - `-w` : warnings
 - `-g` : debug symbols
 
If using a different version of D:
 - `libphobos2.a` is (probably?) found in `/usr/lib/x86_64-linux-gnu/libphobos2.a`
 
 
 
 
 
 
 
