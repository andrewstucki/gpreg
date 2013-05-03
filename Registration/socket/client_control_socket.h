#ifndef __CLIENT_CONTROL_SOCKET_H__
#define __CLIENT_CONTROL_SOCKET_H__

#include <stdint.h>
#include <stdio.h>
#include <pthread.h>
#include <csignal>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#include "protocol.h"

class ClientControlSocket {
public:
    ClientControlSocket(char *address, uint16_t port);
    ~ClientControlSocket();
    int Receive(ControlPacket *control);
    int Send(ControlPacket *control);
    int fd();
    
private:
    uint16_t port_;    
    int socket_fd_;
};

#endif //__CONTROL_SOCKET_H__