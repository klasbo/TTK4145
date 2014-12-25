import  std.stdio,
        std.socket,
        std.concurrency,
        std.file,
        std.getopt,
        std.string,
        std.c.process,
        core.thread;

__gshared ushort comPortToDisplay      = 40000;
__gshared ushort comPortFromDisplay    = 40001;


shared static this(){
    string[] configContents;
    try {
        configContents = readText("simulator.con").split;
        getopt( configContents,
            std.getopt.config.passThrough,
            "comPortToDisplay",     &comPortToDisplay,
            "comPortFromDisplay",   &comPortFromDisplay,
        );
    } catch(Exception e){
        writeln("Unable to load ElevatorConfig: ", e.msg, "\n Using defaults");
    }
}


void thr_controlPanelInput(){
    scope(exit){ writeln(__FUNCTION__, " died"); }

    auto    addr    = new InternetAddress("localhost", comPortFromDisplay);
    auto    sock    = new UdpSocket();

    while(1){
        foreach(ubyte[] buf; stdin.byChunk(1)){
            sock.sendTo(buf, addr);
        }
    }
}

void main(){
    scope(exit){ writeln(__FUNCTION__, " died"); }
    auto    addr    = new InternetAddress("localhost", comPortToDisplay);
    auto    sock    = new UdpSocket();

    ubyte[2048]     buf;

    sock.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, 1);
    sock.bind(addr);

    spawn( &thr_controlPanelInput );

    void cls(){
        version(Windows){
            system("CLS");
        }
        version(linux){
            system("clear");
        }
    }
    
    cls;    
    writeln(q{
QWE, SDF, and ZXCV control the Up, Down and Command buttons.  
T controls the stop button, G toggles the obstruction switch.  
(A keypress must be followed by pressing Enter.)  

The duration of a keypress is set in simulator.con.

Waiting for new state from the simulator...
    });
    
    while(sock.receiveFrom(buf) > 0){
        cls;
        writeln(cast(string)buf);
        buf.destroy;
    }
}
