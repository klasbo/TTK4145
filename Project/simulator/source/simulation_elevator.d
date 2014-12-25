module elevator_driver.simulation_elevator;


import  core.runtime,
        core.thread,
        std.algorithm,
        std.concurrency,
        std.conv,
        std.file,
        std.getopt,
        std.process,
        std.random,
        std.socket,
        std.stdio,
        std.string;

import timer_event;


extern (C) {
    void simulation_elevator_start() {
    
        rt_init;
        
        // --- CONFIG --- //
        string[] configContents;
        try {
            configContents = readText("simulator.con").split;
            getopt( configContents,
                std.getopt.config.passThrough,
                "travelTimeBetweenFloors_ms",   &travelTimeBetweenFloors_ms,
                "travelTimePassingFloor_ms",    &travelTimePassingFloor_ms,
                "btnDepressedTime_ms",          &btnDepressedTime_ms,
                "comPortToDisplay",             &comPortToDisplay,
                "comPortFromDisplay",           &comPortFromDisplay,
            );
        } catch(Exception e){
            writeln("Unable to load ElevatorConfig: ", e.msg, "\n Using defaults");
        }
        
        // --- INIT --- //
        simulationLoop_thread = spawn( &thr_simulationLoop );
        buttons     = new shared bool[][](4, 3);
        lights      = new shared bool[][](4, 3);
        prevFloor   = uniform(minFloor, maxFloor);
        currFloor   = dice(80,20) ? -1 : prevFloor;
        nextFloor   = prevFloor;
        if(currFloor == -1  &&  prevFloor == minFloor){
            prevDir = MotorDirection.UP;
        } else if(currFloor == -1  &&  prevFloor == maxFloor){
            prevDir = MotorDirection.DOWN;
        } else {
            prevDir = dice(50,50) ? MotorDirection.DOWN : MotorDirection.UP;
        }
        currDir = MotorDirection.STOP;
    }

    void simulation_dio_write(int channel, int value){
        switch(channel){
        case LIGHT_UP1:         lights[0][Light.UP]         = value.to!bool;    break;
        case LIGHT_UP2:         lights[1][Light.UP]         = value.to!bool;    break;
        case LIGHT_UP3:         lights[2][Light.UP]         = value.to!bool;    break;
        case LIGHT_DOWN2:       lights[1][Light.DOWN]       = value.to!bool;    break;
        case LIGHT_DOWN3:       lights[2][Light.DOWN]       = value.to!bool;    break;
        case LIGHT_DOWN4:       lights[3][Light.DOWN]       = value.to!bool;    break;
        case LIGHT_COMMAND1:    lights[0][Light.COMMAND]    = value.to!bool;    break;
        case LIGHT_COMMAND2:    lights[1][Light.COMMAND]    = value.to!bool;    break;
        case LIGHT_COMMAND3:    lights[2][Light.COMMAND]    = value.to!bool;    break;
        case LIGHT_COMMAND4:    lights[3][Light.COMMAND]    = value.to!bool;    break;
        case LIGHT_DOOR_OPEN:   doorLight                   = value.to!bool;    break;
        case LIGHT_STOP:        stpBtnLight                 = value.to!bool;    break;
        case LIGHT_FLOOR_IND1:  flrIndLight = (flrIndLight & 0x01) + (value ? 2 : 0);   break;
        case LIGHT_FLOOR_IND2:  flrIndLight = (flrIndLight & 0x02) + (value ? 1 : 0);   break;
        case MOTORDIR:          ioDir       = value ? 1 : 0;                            break;
        default: break;
        }
        simulationLoop_thread.send(StateUpdated());
    }
    
    int simulation_dio_read(int channel){
        switch(channel){
        case BUTTON_UP1:        return buttons[0][ButtonType.UP];
        case BUTTON_UP2:        return buttons[1][ButtonType.UP];
        case BUTTON_UP3:        return buttons[2][ButtonType.UP];
        case BUTTON_DOWN2:      return buttons[1][ButtonType.DOWN];
        case BUTTON_DOWN3:      return buttons[2][ButtonType.DOWN];
        case BUTTON_DOWN4:      return buttons[3][ButtonType.DOWN];
        case BUTTON_COMMAND1:   return buttons[0][ButtonType.COMMAND];
        case BUTTON_COMMAND2:   return buttons[1][ButtonType.COMMAND];
        case BUTTON_COMMAND3:   return buttons[2][ButtonType.COMMAND];
        case BUTTON_COMMAND4:   return buttons[3][ButtonType.COMMAND];
        case SENSOR_FLOOR1:     return currFloor == 0;
        case SENSOR_FLOOR2:     return currFloor == 1;
        case SENSOR_FLOOR3:     return currFloor == 2;
        case SENSOR_FLOOR4:     return currFloor == 3;
        case LIGHT_UP1:         return lights[0][Light.UP];
        case LIGHT_UP2:         return lights[1][Light.UP];
        case LIGHT_UP3:         return lights[2][Light.UP];
        case LIGHT_DOWN2:       return lights[1][Light.DOWN];
        case LIGHT_DOWN3:       return lights[2][Light.DOWN];
        case LIGHT_DOWN4:       return lights[3][Light.DOWN];
        case LIGHT_COMMAND1:    return lights[0][Light.COMMAND];
        case LIGHT_COMMAND2:    return lights[1][Light.COMMAND];
        case LIGHT_COMMAND3:    return lights[2][Light.COMMAND];
        case LIGHT_COMMAND4:    return lights[3][Light.COMMAND];
        case LIGHT_DOOR_OPEN:   return doorLight;
        case LIGHT_STOP:        return stpBtnLight;
        case LIGHT_FLOOR_IND1:  return flrIndLight & 0x01;
        case LIGHT_FLOOR_IND2:  return flrIndLight & 0x02;
        case OBSTRUCTION:       return obstrSwch;
        case STOP:              return stopBtn;
        case MOTORDIR:          return ioDir;
        default:                return 0;
        }
    }
    
    void simulation_data_write(int channel, int value){
        switch(channel){
        case MOTOR:
            motorAnalogVal = value;
            simulationLoop_thread.send(
                motorAnalogVal > 2048
                    ? ioDir 
                        ? MotorDirection.DOWN
                        : MotorDirection.UP
                    : MotorDirection.STOP
            );
            break;
        default: break;
        }
    }
    
    int simulation_data_read(int channel){
        switch(channel){
        case MOTOR:             return motorAnalogVal;
        default:                return 0;
        }
    }
}


private {

enum ButtonType : int {
    UP=0,
    DOWN=1,
    COMMAND=2
}

enum Light : int {
    UP=0,
    DOWN=1,
    COMMAND=2,
    FLOOR_INDICATOR,
    STOP,
    DOOR_OPEN
}

enum MotorDirection {
    UP,
    DOWN,
    STOP
}


const int OBSTRUCTION      = (0x300+23);
const int STOP             = (0x300+22);
const int BUTTON_COMMAND1  = (0x300+21);
const int BUTTON_COMMAND2  = (0x300+20);
const int BUTTON_COMMAND3  = (0x300+19);
const int BUTTON_COMMAND4  = (0x300+18);
const int BUTTON_UP1       = (0x300+17);
const int BUTTON_UP2       = (0x300+16);
const int BUTTON_DOWN2     = (0x200+0);
const int BUTTON_UP3       = (0x200+1);
const int BUTTON_DOWN3     = (0x200+2);
const int BUTTON_DOWN4     = (0x200+3);
const int SENSOR_FLOOR1    = (0x200+4);
const int SENSOR_FLOOR2    = (0x200+5);
const int SENSOR_FLOOR3    = (0x200+6);
const int SENSOR_FLOOR4    = (0x200+7);
const int MOTORDIR         = (0x300+15);
const int LIGHT_STOP       = (0x300+14);
const int LIGHT_COMMAND1   = (0x300+13);
const int LIGHT_COMMAND2   = (0x300+12);
const int LIGHT_COMMAND3   = (0x300+11);
const int LIGHT_COMMAND4   = (0x300+10);
const int LIGHT_UP1        = (0x300+9);
const int LIGHT_UP2        = (0x300+8);
const int LIGHT_DOWN2      = (0x300+7);
const int LIGHT_UP3        = (0x300+6);
const int LIGHT_DOWN3      = (0x300+5);
const int LIGHT_DOWN4      = (0x300+4);
const int LIGHT_DOOR_OPEN  = (0x300+3);
const int LIGHT_FLOOR_IND2 = (0x300+1);
const int LIGHT_FLOOR_IND1 = (0x300+0);
const int MOTOR            = (0x100+0);




// Threads
Tid                     simulationLoop_thread;
Tid                     timerEvent_thread;
Tid                     controlPanelInput_thread;

// Position and direction
shared int              currFloor;
shared int              prevFloor;
shared int              nextFloor;
shared MotorDirection   currDir;
shared MotorDirection   prevDir;

shared int              ioDir;
shared int              motorAnalogVal;

// Buttons & switches
shared bool[][]         buttons;
shared bool             stopBtn;
shared bool             obstrSwch;

// Lights
shared bool[][]         lights;
shared int              flrIndLight;
shared bool             stpBtnLight;
shared bool             doorLight;

// Printing
int                     printCount;
InternetAddress         addr;
Socket                  sock;

// Config
__gshared uint          travelTimeBetweenFloors_ms  = 1500;
Duration                travelTimeBetweenFloors;
__gshared uint          travelTimePassingFloor_ms   = 650;
Duration                travelTimePassingFloor;
__gshared uint          btnDepressedTime_ms         = 200;
Duration                btnDepressedTime;
__gshared ushort        comPortToDisplay            = 40000;
__gshared ushort        comPortFromDisplay          = 40001;

immutable int           minFloor        = 0;
immutable int           maxFloor        = 3;



void thr_simulationLoop(){
    scope(failure){
        writeln(__FUNCTION__, " died");
        writeln("Debug info:\nprevDir=", prevDir, "\ncurrDir=", currDir,
                "\nprevFloor=", prevFloor, "\ncurrFloor=", currFloor,
                "\nnextFloor=", nextFloor);
    }
    try {

    // --- INIT --- //


    timerEvent_thread           = spawn( &timerEvent_thr );
    controlPanelInput_thread    = spawn( &thr_controlPanelInput );

    travelTimeBetweenFloors     = travelTimeBetweenFloors_ms.msecs;
    travelTimePassingFloor      = travelTimePassingFloor_ms.msecs;
    btnDepressedTime            = btnDepressedTime_ms.msecs;
    addr                        = new InternetAddress("localhost", comPortToDisplay);
    sock                        = new UdpSocket();
    sock.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, 1);



    // --- LOOP --- //
    printState;
    while(1){
        receive(
            (MotorDirection m){
                // writeln("received MotorDirChange: prevDir=", prevDir, " currDir=", currDir,
                //                                 " prevFloor=", prevFloor, " currFloor=", currFloor,
                //                                 " m=", m);
                currDir = m;
                final switch(currDir) with(MotorDirection){
                case UP:
                    if(currFloor != -1){
                        timerEvent_thread.send(thisTid, "dep"~currFloor.to!string, travelTimePassingFloor);
                    } else {
                        if(prevDir == MotorDirection.UP){
                            timerEvent_thread.send(thisTid, "arr"~(prevFloor+1).to!string, travelTimeBetweenFloors);
                            nextFloor = prevFloor+1;
                        }
                        if(prevDir == MotorDirection.DOWN){
                            timerEvent_thread.send(thisTid, "arr"~(prevFloor).to!string, travelTimeBetweenFloors);
                        }
                    }
                    prevDir = currDir;
                    break;
                case DOWN:
                    if(currFloor != -1){
                        timerEvent_thread.send(thisTid, "dep"~currFloor.to!string, travelTimePassingFloor);
                    } else {
                        if(prevDir == MotorDirection.UP){
                            timerEvent_thread.send(thisTid, "arr"~(prevFloor).to!string, travelTimeBetweenFloors);
                        }
                        if(prevDir == MotorDirection.DOWN){
                            timerEvent_thread.send(thisTid, "arr"~(prevFloor-1).to!string, travelTimeBetweenFloors);
                            nextFloor = prevFloor-1;
                        }
                    }
                    prevDir = currDir;
                    break;
                case STOP:
                    break;
                }
            },
            (Tid t, string s){
                if(t == timerEvent_thread){
                    handleTimerEvent(s);
                }
            },
            (immutable(ubyte)[] b){
                handleStdinEvent(b[0].to!char);
            },
            (StateUpdated su){
            },
            (OwnerTerminated ot){
                return;
            }
        );
        printState;
    }
    } catch(Throwable t){ t.writeln; throw t; }
}



void handleTimerEvent(string s){
    switch(s[0..3]){
        case "arr":
            if(currDir != MotorDirection.STOP){
                if(s[3] == '-'  || s[3] == '4'){
                    throw new ElevatorCrash("\nELEVATOR HAS CRASHED: \"Arrived\" at a non-existent floor\n");
                }
                if(currDir == MotorDirection.UP    &&  (s[3]-'0').to!int < prevFloor){ return; }
                if(currDir == MotorDirection.DOWN  &&  (s[3]-'0').to!int > prevFloor){ return; }
                currFloor = prevFloor = (s[3]-'0').to!int;
                timerEvent_thread.send(thisTid, "dep"~currFloor.to!string, travelTimePassingFloor);
                return;
            }
            if(currDir == MotorDirection.STOP){
                // ignore, elevator stopped before it reached the floor
            }
            return;

        case "dep":
            if(currDir == MotorDirection.UP){
                if(s[3] == '3'){
                    throw new ElevatorCrash("\nELEVATOR HAS CRASHED: Departed top floor going upward\n");
                }
                currFloor = -1;
                timerEvent_thread.send(thisTid, "arr"~(prevFloor+1).to!string, travelTimeBetweenFloors);
                nextFloor = prevFloor+1;
                return;
            }
            if(currDir == MotorDirection.DOWN){
                if(s[3] == '0'){
                    throw new ElevatorCrash("\nELEVATOR HAS CRASHED: Departed bottom floor going downward\n");
                }
                currFloor = -1;
                timerEvent_thread.send(thisTid, "arr"~(prevFloor-1).to!string, travelTimeBetweenFloors);
                nextFloor = prevFloor-1;
                return;
            }
            return;

        case "btn":
            switch(s[3]){
                case 'u': buttons[(s[4]-'0').to!int][0] = false; return;
                case 'd': buttons[(s[4]-'0').to!int][1] = false; return;
                case 'c': buttons[(s[4]-'0').to!int][2] = false; return;
                default: writeln("Bad timer event received: unable to parse \"", s, "\""); return;
            }

        case "stp":
            stopBtn = false;
            return;

        default:
            writeln("Bad timer event received: unable to parse \"", s, "\"");
            return;
    }
}


void handleStdinEvent(char c){
    switch(c){
        case 'q': // 0 up
            buttons[0][ButtonType.UP] = true;
            timerEvent_thread.send(thisTid, "btnu0", btnDepressedTime);
            break;
        case 'w': // 1 up
            buttons[1][ButtonType.UP] = true;
            timerEvent_thread.send(thisTid, "btnu1", btnDepressedTime);
            break;
        case 'e': // 2 up
            buttons[2][ButtonType.UP] = true;
            timerEvent_thread.send(thisTid, "btnu2", btnDepressedTime);
            break;
        case 's': // 1 dn
            buttons[1][ButtonType.DOWN] = true;
            timerEvent_thread.send(thisTid, "btnd1", btnDepressedTime);
            break;
        case 'd': // 2 dn
            buttons[2][ButtonType.DOWN] = true;
            timerEvent_thread.send(thisTid, "btnd2", btnDepressedTime);
            break;
        case 'f': // 3 dn
            buttons[3][ButtonType.DOWN] = true;
            timerEvent_thread.send(thisTid, "btnd3", btnDepressedTime);
            break;
        case 'z': // 0 cm
            buttons[0][ButtonType.COMMAND] = true;
            timerEvent_thread.send(thisTid, "btnc0", btnDepressedTime);
            break;
        case 'x': // 1 cm
            buttons[1][ButtonType.COMMAND] = true;
            timerEvent_thread.send(thisTid, "btnc1", btnDepressedTime);
            break;
        case 'c': // 2 cm
            buttons[2][ButtonType.COMMAND] = true;
            timerEvent_thread.send(thisTid, "btnc2", btnDepressedTime);
            break;
        case 'v': // 3 cm
            buttons[3][ButtonType.COMMAND] = true;
            timerEvent_thread.send(thisTid, "btnc3", btnDepressedTime);
            break;
        case 't': // stop
            stopBtn = true;
            timerEvent_thread.send(thisTid, "stp", btnDepressedTime);
            break;
        case 'g': // obst
            obstrSwch = !obstrSwch;
            break;
        default: break;
    }
}



void thr_controlPanelInput(){
    scope(exit){ writeln(__FUNCTION__, " died"); }

    ubyte[1] buf;
    auto    addr    = new InternetAddress("localhost", comPortFromDisplay);
    auto    sock    = new UdpSocket();

    sock.bind(addr);

    while(sock.receive(buf) > 0){
        ownerTid.send(buf.idup);
    }
}



void printState(){

    char[][] bg = [
        "+---------------+ +----+--------------+---------+",
        "|               | |  up| 0  1  2      | obstr:  |",
        "| 0 - 1 - 2 - 3 | |down|    1  2  3   | door:   |",
        "|       -       | | cmd| 0  1  2  3   | stop:   |",
        "+---------------+ +----+--------------+---------+" ].to!(char[][]);

/+
    writeln("debug printState:",
        " prevDir=", prevDir,
        " currDir=", currDir,
        " prevFloor=", prevFloor,
        " currFloor=", currFloor,
        " nextFloor=", nextFloor);
+/


    // Elevator position
    if(currFloor != -1){
        bg[1][2+currFloor*4] = '#';
    } else {
        if(nextFloor > prevFloor){
            bg[1][4+prevFloor*4] = '#';
        }
        if(nextFloor < prevFloor){
            bg[1][0+prevFloor*4] = '#';
        }
        if(nextFloor == prevFloor){
            if(prevDir == MotorDirection.UP){
                bg[1][4+prevFloor*4] = '#';
            }
            if(prevDir == MotorDirection.DOWN){
                bg[1][0+prevFloor*4] = '#';
            }
        }

    }

    // Elevator Direction
    if(currDir == MotorDirection.DOWN){
        bg[3][7]  = '<';
    }
    if(currDir == MotorDirection.UP){
        bg[3][9]  = '>';
    }

    // Button lights
    foreach(floor, lightsAtFloor; lights){ //0..3
        foreach(light, on; lightsAtFloor){  //0..2
            if(on){
                bg[light+1][26+floor*3] = '*';
            }
        }
    }
    // Other lights
    bg[2][3+flrIndLight*4] = '*';
    if(obstrSwch){
        bg[1][46] = '^';
    }
    if(doorLight){
        bg[2][46] = '*';
    }
    if(stpBtnLight){
        bg[3][46] = '*';
    }

    auto c = printCount++.to!(char[]);
    bg[4][48-c.length..48] = c[0..$];

    sock.sendTo(bg.reduce!((a, b) => a ~ "\n" ~ b), addr);

}


class ElevatorCrash : Exception {
    this(string msg){
        super(msg);
    }
}

struct StateUpdated {}


}

