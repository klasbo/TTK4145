// Wrapper for libComedi Elevator control.
// These functions provides an interface to the elevators in the real time lab
//
// 2007, Martin Korsgaard


#include "channels.h"
#include "elev.h"
#include "io.h"

#include <assert.h>
#include <stdlib.h>

// Number of signals and lamps on a per-floor basis (excl sensor)
#define N_BUTTONS 3


static const int lamp_channel_matrix[N_FLOORS][N_BUTTONS] = {
    {LIGHT_UP1, LIGHT_DOWN1, LIGHT_COMMAND1},
    {LIGHT_UP2, LIGHT_DOWN2, LIGHT_COMMAND2},
    {LIGHT_UP3, LIGHT_DOWN3, LIGHT_COMMAND3},
    {LIGHT_UP4, LIGHT_DOWN4, LIGHT_COMMAND4},
};
  
  

static const int button_channel_matrix[N_FLOORS][N_BUTTONS] = {
    {FLOOR_UP1, FLOOR_DOWN1, FLOOR_COMMAND1},
    {FLOOR_UP2, FLOOR_DOWN2, FLOOR_COMMAND2},
    {FLOOR_UP3, FLOOR_DOWN3, FLOOR_COMMAND3},
    {FLOOR_UP4, FLOOR_DOWN4, FLOOR_COMMAND4},
};
 
 
 
int elev_init(void){
    // Init hardware
    if (!io_init())
        return 0;

    // Zero all floor button lamps
    for (int i = 0; i < N_FLOORS; ++i) {
        if (i != 0)
            elev_set_button_lamp(BUTTON_CALL_DOWN, i, 0);

        if (i != N_FLOORS-1)
            elev_set_button_lamp(BUTTON_CALL_UP, i, 0);

        elev_set_button_lamp(BUTTON_COMMAND, i, 0);
    }

    // Clear stop lamp, door open lamp, and set floor indicator to ground floor.
    elev_set_stop_lamp(0);
    elev_set_door_open_lamp(0);
    elev_set_floor_indicator(0);

    // Return success.
    return 1;
}



void elev_set_speed(int speed){
    // In order to sharply stop the elevator, the direction bit is toggled
    // before setting speed to zero.
    static int last_speed = 0;
    
    // If to start (speed > 0)
    if (speed > 0)
        io_clear_bit(MOTORDIR);
    else if (speed < 0)
        io_set_bit(MOTORDIR);

    // If to stop (speed == 0)
    else if (last_speed < 0)
        io_clear_bit(MOTORDIR);
    else if (last_speed > 0)
        io_set_bit(MOTORDIR);

    last_speed = speed ;

    // Write new setting to motor.
    io_write_analog(MOTOR, 2048 + 4*abs(speed));
}



int elev_get_floor_sensor_signal(void){
    if (io_read_bit(SENSOR1))
        return 0;
    else if (io_read_bit(SENSOR2))
        return 1;
    else if (io_read_bit(SENSOR3))
        return 2;
    else if (io_read_bit(SENSOR4))
        return 3;
    else
        return -1;
}



int elev_get_button_signal(elev_button_type_t button, int floor){
    assert(floor >= 0);
    assert(floor < N_FLOORS);
    assert(!(button == BUTTON_CALL_UP && floor == N_FLOORS-1));
    assert(!(button == BUTTON_CALL_DOWN && floor == 0));
    assert( button == BUTTON_CALL_UP || 
            button == BUTTON_CALL_DOWN || 
            button == BUTTON_COMMAND);

    if (io_read_bit(button_channel_matrix[floor][button]))
        return 1;
    else
        return 0;
}



int elev_get_stop_signal(void){
    return io_read_bit(STOP);
}



int elev_get_obstruction_signal(void){
    return io_read_bit(OBSTRUCTION);
}



void elev_set_floor_indicator(int floor){
    assert(floor >= 0);
    assert(floor < N_FLOORS);

    // Binary encoding. One light must always be on.
    if (floor & 0x02)
        io_set_bit(FLOOR_IND1);
    else
        io_clear_bit(FLOOR_IND1);
        
    if (floor & 0x01)
        io_set_bit(FLOOR_IND2);
    else
        io_clear_bit(FLOOR_IND2);
}



void elev_set_button_lamp(elev_button_type_t button, int floor, int value){
    assert(floor >= 0);
    assert(floor < N_FLOORS);
    assert(!(button == BUTTON_CALL_UP && floor == N_FLOORS-1));
    assert(!(button == BUTTON_CALL_DOWN && floor == 0));
    assert( button == BUTTON_CALL_UP ||
            button == BUTTON_CALL_DOWN ||
            button == BUTTON_COMMAND);

    if (value == 1)
        io_set_bit(lamp_channel_matrix[floor][button]);
    else
        io_clear_bit(lamp_channel_matrix[floor][button]);        
}



void elev_set_stop_lamp(int value){
    if (value)
        io_set_bit(LIGHT_STOP);
    else
        io_clear_bit(LIGHT_STOP);
}



void elev_set_door_open_lamp(int value){
    if (value)
        io_set_bit(DOOR_OPEN);
    else
        io_clear_bit(DOOR_OPEN);
}








