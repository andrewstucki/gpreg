#ifndef __UDP_SOCKET_H__
#define __UDP_SOCKET_H__

#include <stdexcept>

#include <stdint.h>
#include <unistd.h>

#include "protocol.h"
#include "address.h"

class SocketError : public std::runtime_error {
public:
    explicit SocketError(const char *msg) : std::runtime_error(msg) {};
};

class UDPSocket {
public:
    UDPSocket(uint16_t port);
    ~UDPSocket();
    size_t Receive(BeaconPacket *beacon, NetworkAddress *address);
    size_t Send(BeaconPacket *beacon, NetworkAddress *address);
    int fd();
private:
    uint16_t port_;
    int socket_fd_;
};

#endif //__UDP_SOCKET_H__