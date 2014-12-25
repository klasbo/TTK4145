module  timer_event;


import  core.thread,
        std.algorithm,
        std.concurrency,
        std.conv,
        std.datetime,
        std.range,
        std.stdio,
        std.string;

//debug = timerEvent_thr;


enum EventType {
    oneshot,
    periodic
}
struct CancelEvent {
}

void timerEvent_thr(){
    scope(failure){
        writeln(__FUNCTION__, " died");
    }

try{


    struct Event {
        Tid         owner;
        string      name;
        SysTime     time;
        Duration    period;

        string toString(){
            return "Event("
                    ~ name  ~ ", "
                    ~ time.to!string ~ ", "
                    ~ period.to!string ~ ")";
        }
    }


    Event[]     events;
    Duration    timeUntilNextEvent  = 1.hours;
    Duration    eventMinimumPeriod  = 5.msecs;
    bool        isDone              = false;


    void AddEvent(Tid owner, string eventName, SysTime timeOfEvent, Duration period, EventType type){
        // If the event exists: update event.time and event.period
        foreach(ref event; events){
            if(owner == event.owner  &&  eventName == event.name){
                final switch(type) with(EventType){
                case periodic:
                    event = Event(owner, eventName, timeOfEvent + period, period);
                    break;
                case oneshot:
                    event = Event(owner, eventName, timeOfEvent, 0.msecs);
                    break;
                }
                return;
            }
        }
        
        // Else: add new event
        if(type == EventType.periodic  &&  period < eventMinimumPeriod){
            debug writeln("Failure to add new event: Event period is too fast");
            return;
        }
        final switch(type) with(EventType){
        case periodic:
            events ~= Event(owner, eventName, timeOfEvent + period, period);
            break;
        case oneshot:
            events ~= Event(owner, eventName, timeOfEvent, 0.msecs);
            break;
        }
    }

    while(true){
        receiveTimeout( timeUntilNextEvent,
            // in [time] timeunits (implicit oneshot)
            (Tid owner, string eventName, Duration time){
                AddEvent(owner, eventName, Clock.currTime + time, 0.msecs, EventType.oneshot);
            },
            // in [time] timeunits, with type
            (Tid owner, string eventName, Duration time, EventType type){
                AddEvent(owner, eventName, Clock.currTime + time, time, type);
            },
            // at [time] (implicit oneshot)
            (Tid owner, string eventName, SysTime time){
                    AddEvent(owner, eventName, time, 0.msecs, EventType.oneshot);
            },
            // cancel event
            (Tid owner, string eventName, CancelEvent ce){
                foreach(idx, event; events){
                    if(owner == event.owner  &&  eventName == event.name){
                        events = events.remove(idx);
                        break;
                    }
                }
            },
            (OwnerTerminated ot){
                isDone = true;
            },
            (LinkTerminated lt){
                isDone = true;
            },
            (Variant v){
                writeln(__FUNCTION__,":",__LINE__," Unhandled input: ", v);
            }
        );
        
        
        if(isDone){
            return;
        }


        // Go through all events. If one has passed, send back event & update events list
        iter:
        events.sort!("a.time < b.time");
        foreach(idx, ref event; events){
            timeUntilNextEvent = event.time - Clock.currTime;
            if(timeUntilNextEvent <= 0.msecs){

                event.owner . send(thisTid, event.name);

                if(event.period >= eventMinimumPeriod){
                    event.time += event.period;
                } else {
                    events = events.remove(idx);
                }
                goto iter;  // Do not foreach over a list that is being modified
            }
        }



        // Set the time until next event to the shortest time
        events.sort!("a.time < b.time");
        if(events.length > 0){
            timeUntilNextEvent = events.front.time - Clock.currTime;
            if(timeUntilNextEvent <= 0.msecs){
                timeUntilNextEvent = 0.msecs;
            }
        } else {
            timeUntilNextEvent = 1.hours;
        }
    }
}
catch(Throwable t){ t.writeln; }
}
