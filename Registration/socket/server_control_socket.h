#ifndef __SERVER_CONTROL_SOCKET_H__
#define __SERVER_CONTROL_SOCKET_H__

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
#include "server.h"

class ServerControlSocket;
class RegistrationServer;

class ServerControlSocketWorker {
public:
    ServerControlSocketWorker(ServerControlSocket *parent, int client_socket);
    ~ServerControlSocketWorker();
    void HandleClient();
    int SetupFinished();
    
private:
    ServerControlSocket *parent_;
    int client_socket_;
    int finished_setup_;
};

class ServerControlSocket {
public:
    ServerControlSocket(char *address, uint16_t port, RegistrationServer *server);
    ~ServerControlSocket();
    int ReceiveAndRespond();
    int fd();
private:
    void Lock();
    void SignalWorkerSetupFinished();
    void ConditionedWait();
    void Unlock();
    int Listen();

    pthread_mutex_t lock_;
    pthread_cond_t cv_setup_done_;
    pthread_t listen_thread_;
    uint16_t port_;
    
    int server_socket_;
    RegistrationServer *server_;
    
    static void * Listen(void * This) {((ServerControlSocket *)This)->Listen(); return NULL;}
    static void * HandleClient(void * Worker) {((ServerControlSocketWorker *)Worker)->HandleClient(); return NULL;}

    friend class ServerControlSocketWorker;
};

#endif //__SERVER_CONTROL_SOCKET_H__