Pseudocode
==========

TCP
---
Most TCP sockets will not return unless their eintire buffer has been filled. Either accept fixed-size messages of size 1024 (which is what the server sends), or find some functionality that avoids this.

With diagram: [Berkeley Sockets](http://en.wikipedia.org/wiki/Berkeley_sockets) on Wikipedia

###Client
    addr = new InternetAddress(serverIP, serverPort) 
    sock = new Socket(tcp) // TCP, aka SOCK_STREAM
    sock.connect(addr)
    // use sock.recv() and sock.send()
    
###Server
    // Send a message to the server:  "Connect to: " ~ your IP ~ ":" ~ port ~ "\0"
    
    // do not need IP, because we will set it to listening state
    addr = new InternetAddress(localPort)
    acceptSock = new Socket(tcp)
    
    // You may not be able to use the same port twice when you restart the program, unless you set this option
    acceptSock.setOption(reuseAddr, true)
    acceptSock.bind(addr)
    // backlog = Max number of pending connections waiting to connect()
    newSock = acceptSock.listen(backlog)
    
    // Spawn new thread to handle recv()/send() on newSock
    
   
UDP   
---
UDP ues datagrams, so receiveFrom will return whenever it receives anything. The buffer size is just the maximum size of the message, it doesn't have to be "filled".

###Sender
    // broadcastIP = #.#.#.255. First three bytes are from the local IP
    addr = new InternetAddress(broadcastIP, port)
    sendSock = new Socket(udp) // UDP, aka SOCK_DGRAM
    sendSock.setOption(broadcast, true)
    sendSock.sendTo(message, addr)
###Receiver
    byte[1024]      buffer
    InternetAddress fromWho
    recvSock = new Socket(udp)
    recvSock.bind(addr)         // same addr as sender
    loop {
        buffer.clear
        // fromWho will be modified by ref here. Or it's a return value. Depends.
        recvSock.receiveFrom(buffer, ref fromWho)
        if(fromWho.IP != localIP){      // check we are not receiving from ourselves
            // do stuff with buffer
        }
    }
    
    
Shutting down sockets
=====================
Use SocketOption REUSEADDRESS, so you can use the same address when the program restarts. This way you can be lazy, and not use the proper shutdown()/close() calls.


Non-blocking sockets and select()
=================================
###Aka avoiding the use of a new thread for each connection

[From the Python Sockets HowTo](http://docs.python.org/2/howto/sockets.html#non-blocking-sockets), but the concept is the same in any language.
