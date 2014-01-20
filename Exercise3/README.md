Exercise 3 : Simon Says Connect
===============================

Background
----------

This exercise is part of of a three-stage process:
 - This first exercise is to make you more familiar with using TCP and UDP for communication between processes running on different machines. You are of course free to do the UDP exercise before the TCP one. Do not think too much about code quality here, as the main goal is familiarization with the protocols.
 - Exercsie 4 will have you consider the things you have learned about these two protocols, and implement a network module that you can use in the project itself. The communication that is necessary for your design should reflect your choice of protocol. This is when you should start thinking more about code quality, because ...
 - Finally, you should be able to use this module as part of your project. Since predicting the future is notoriously difficult, you may find you need to change some functionality. But if the module has well-defined boundaries, you should be able to swap out the entire thing if necessary...


Note: 
 - You are free to choose any language. Using the same language on the network exercises and the project is reccomended, but not required. If you are still in the process of deciding, use this exercise as a case study.
 - This is also a good time to make serious use of source control, as you will hopefully be able to use the code you create in the project.
 - Exactly how you do communication for the project is up to you, so if you want to venture out into the land of libraries, you should make sure that the library satisfies all your requirements. You should also check the license.
 
___

There are three common ways to format a message: (Though there are probably others)
 - 1: Always send fixed-sized messages
 - 2: Send the message size with each message
 - 3: Use a marker system to separate messages 

The TCP server can send you two of these:
 - Fixed size messages of size `1024`, if you connect to port `34933`
 - Delimited messages that use `\0` as the marker, if you connect to port `33546`
 
The server will read until it encounters the first `\0`, regardless.

Sharing a socket between threads should not be a problem, although reading from a socket in two threads will probably mean that only one of the threads get the message. If you are using blocking sockets, you could create a "receiving"-thread for each socket. Alternatively, you can use socket sets and a select-statement.

Be nice to the network: Put some amount of `sleep()` or equivalent in the loops that send messages. The network at the lab will be shut off if IT finds a DDOS-esque level of traffic. Yes, this has happened before. Several times.
    
    
Exercise
--------

###TCP:
The server address will be on a piece of paper somewhere (the address depends on what computer is running it).
####1:
 - Connect to the TCP server. It will send you a welcome-message when you connect.
 - The server will then echo anything you say to it back to you (as long as your message ends with '\0'). Try sending and receiving a few messages.
 
####2:
 - Tell the server to connect back to you, by sending a message of the form `Connect to: #.#.#.#:#\0` (IP of your machine and port you are listening to). You can find your own address by running `ifconfig` in the terminal. It should be of the form `129.241.187.#`
 - This new connection will behave the same way on the server-side, so you can send messages and receive echoes in the same way as before. You can even have it "Connect to" recursively (but please be nice...)
 
####3 (optional):
 - Play a game of Simon says: Send "Play Simon says" to the server to start a game.
 - For each message you receive: if a message starts with "Simon says ", reply with the message content; otherwise, do nothing.
 - The messages will start simple, but eventually try to crash your client by sending you stupid things.
 - You've won when you receive the message "Congratulations! Simon gave up.", or you've lost if you receive the message "Game over."
        
        
###UDP:
Since UDP is connection-less, there are no welcome-messages or games to play. If we want to do games, we need to introduce sequence numbers in the messages, which means we would be well on our way to reimplementing TCP.
 - Connect to the UDP server. Use port number `20000 + n`, where `n` is the number of the workspace you are sitting at (eg workspace 8 would use port 20008). You are free to mess with the people around you by using the same port as them, but they may not appreciate it.
 - The sever will echo anything you send to it. Try sending and receiving a few messages.
 - You may need two sockets: one for sending (broadcast on 129.241.187.255) and one for receiving. Using broadcast also means that the messages will loop back to you. The server prefixes its reply with "You said: ", so you can tell if you are getting a reply from the server or if you are just listening to yourself.
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
