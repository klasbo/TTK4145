#include "elev.h"
#include <stdio.h>


int main(){
    // Initialize hardware
    if (!elev_init()) {
        printf(__FILE__ ": Unable to initialize elevator hardware\n");
        return 1;
    }
    
    printf("Press STOP button to stop elevator and exit program.\n");

    elev_set_speed(300);
      
    while (1) {
        if (elev_get_floor_sensor_signal() == 0){
            elev_set_speed(300);
        } else if (elev_get_floor_sensor_signal() == N_FLOORS-1){
            elev_set_speed(-300);
        }

        if (elev_get_stop_signal()) {
            elev_set_speed(0);
            break;
        }
    }

    return 0;
}

