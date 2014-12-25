
#ifndef __INCLUDE_IO_H__
#define __INCLUDE_IO_H__

/*
This module is initialized with one of the following ElevatorTypes:
*/
typedef enum {
    // Interfaces with the hardware at the Real-time Lab using libcomedi
    ET_comedi,
    
    // Communicates with simulator_interface, that displays the
    // elevator state and handles user input
    ET_simulation
} ElevatorType;


// Returns 0 on init failure
int io_init(ElevatorType type);

void io_set_bit(int channel);
void io_clear_bit(int channel);
void io_write_analog(int channel, int value);
int io_read_bit(int channel);
int io_read_analog(int channel);

#endif

