#include "address.h"
#include <arpa/inet.h>

NetworkAddress CreateNetworkAddress(uint32_t port)
{
    struct sockaddr_in address = { 0 };
    address.sin_family = AF_INET;
    address.sin_port = htons(port);
    address.sin_addr.s_addr = htonl(INADDR_ANY);
    return (NetworkAddress)address;
}

NetworkAddress CreateBroadcastAddress(uint32_t port)
{
    struct sockaddr_in address = { 0 };
    address.sin_family = AF_INET;
    address.sin_port = htons(port);
    //address.sin_addr.s_addr = htonl(INADDR_ANY);
    inet_aton("255.255.255.255", &address.sin_addr);
    return (NetworkAddress)address;
}