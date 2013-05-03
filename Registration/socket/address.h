#ifndef __ADDRESS_H__
#define __ADDRESS_H__

#include <netinet/in.h>
#include <stdint.h>

typedef struct sockaddr_in NetworkAddress;

NetworkAddress CreateNetworkAddress(uint32_t port);
NetworkAddress CreateBroadcastAddress(uint32_t port);

#endif