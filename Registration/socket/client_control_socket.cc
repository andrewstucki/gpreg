#include "client_control_socket.h"

//----------------------------------------
// Constructor and Destructor
//----------------------------------------
ClientControlSocket::ClientControlSocket(char *address, uint16_t port)
{
	struct addrinfo hints, *res, *p;
	
	memset(&hints, 0, sizeof(hints));
	hints.ai_family = AF_UNSPEC;
	hints.ai_socktype = SOCK_STREAM;

    char port_[16];
    snprintf(port_, sizeof(port_), "%d", port);

	if (getaddrinfo("localhost", port_, &hints, &res) != 0)
	{
		perror("getaddrinfo() failed");
		return;
	}

	for(p = res;p != NULL; p = p->ai_next) 
	{
		if ((socket_fd_ = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) 
		{
            int on = 1 ;
		    setsockopt(socket_fd_, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
            
			perror("Could not open socket");
			continue;
		}

		if (connect(socket_fd_, p->ai_addr, p->ai_addrlen) == -1) 
		{
			close(socket_fd_);
			perror("Could not connect to socket");
			continue;
		}

		break;
	}
	
	if (p == NULL)
	{
        fprintf(stderr, "Could not find a socket to connect to.\n");
	}
	
	freeaddrinfo(res);
}

ClientControlSocket::~ClientControlSocket()
{
    close(socket_fd_);
}

//----------------------------------------
// Send/Receive
//----------------------------------------
int ClientControlSocket::Receive(ControlPacket *control)
{   
    size_t nbytes;
    char buffer[100];
    nbytes = recv(socket_fd_, buffer, sizeof(buffer), 0);
    
    LineToControlPacket(buffer, control);
    
    if(nbytes > 0)
        return 1;
    return 0;
}

int ClientControlSocket::Send(ControlPacket *control)
{
    LinePacket lp = ControlPacketToLinePacket(control);
    send(socket_fd_, lp.packet_data, lp.packet_length, 0);
    DeleteLinePacket(&lp);
    return 1;
}

//----------------------------------------
// Accessor
//----------------------------------------
int ClientControlSocket::fd()
{
    return socket_fd_;
}