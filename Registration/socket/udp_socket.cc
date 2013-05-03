#include <sys/socket.h>
#include <errno.h>
#include <string.h>

#include "address.h"
#include "udp_socket.h"

class SocketAllocationException : public SocketError
{
public:
    SocketAllocationException() : SocketError("Failed to initialized UDP socket") {};
};

class SocketOptionException : public SocketError
{
public:
    SocketOptionException() : SocketError("Failed to set UDP sockopt.") {};    
};

class BindException : public SocketError
{
public:
    BindException() : SocketError("Failed to bind UDP socket to port.") {};    
};

UDPSocket::UDPSocket(uint16_t port)
{
    NetworkAddress address = CreateNetworkAddress(port);
    if ((socket_fd_ = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1)
        throw SocketAllocationException();

    int on = 1;
    if (setsockopt (socket_fd_, SOL_SOCKET, SO_BROADCAST, &on, sizeof (on)) == -1)
        throw SocketOptionException();
    setsockopt(socket_fd_, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
    
    if (bind (socket_fd_, (struct sockaddr *)&address, sizeof(address)) == -1)
        printf("%s\n", strerror(errno)); //throw BindException();
}

UDPSocket::~UDPSocket()
{
    close(socket_fd_);
}

size_t UDPSocket::Receive(BeaconPacket *beacon, NetworkAddress *address)
{
    socklen_t address_len = sizeof(NetworkAddress);
    ssize_t size = recvfrom(socket_fd_, beacon, sizeof(BeaconPacket), 0, (struct sockaddr *)address, &address_len);
    return size;
}

size_t UDPSocket::Send(BeaconPacket *beacon, NetworkAddress *address)
{
    return sendto(socket_fd_, beacon, sizeof(BeaconPacket), 0, (struct sockaddr *)address, sizeof(NetworkAddress));
}

int UDPSocket::fd()
{
    return socket_fd_;
}
