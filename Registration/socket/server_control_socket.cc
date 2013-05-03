#include "server_control_socket.h"

//----------------------------------------
// Threaded socket Constructor/Destructor
//----------------------------------------
ServerControlSocket::ServerControlSocket(char *address, uint16_t port, RegistrationServer *server)
{
    pthread_mutexattr_t   mta;
    pthread_mutexattr_init(&mta);
    pthread_mutexattr_settype(&mta, PTHREAD_MUTEX_RECURSIVE);
    
    port_ = port;
    server_ = server;
    sigset_t mask;
    sigemptyset (&mask);
    sigaddset(&mask, SIGPIPE);
    if (pthread_sigmask(SIG_BLOCK, &mask, NULL) != 0) 
    {
    	perror("Unable to mask SIGPIPE");
        return;//exit(-1);
    }
    pthread_mutex_init(&lock_, &mta);
	pthread_cond_init(&cv_setup_done_, NULL);
	
    if(Listen() == 0){
        perror("Unable to listen on socket");
    }
}

ServerControlSocket::~ServerControlSocket()
{
    pthread_join(listen_thread_, NULL);
    pthread_mutex_destroy(&lock_);
    pthread_cond_destroy(&cv_setup_done_);
}

//----------------------------------------
// Binding setup function
//----------------------------------------
int ServerControlSocket::Listen()
{
	struct addrinfo hints, *res, *p;
	int yes = 1;

	memset(&hints, 0, sizeof hints);
	hints.ai_family = AF_UNSPEC;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_flags = AI_PASSIVE;

    char port[16];
    snprintf(port, sizeof(port), "%d", port_);

	if (getaddrinfo(NULL, port, &hints, &res) != 0)
	{
		perror("getaddrinfo() failed");
        return 0;
	}

	for(p = res;p != NULL; p = p->ai_next) 
	{
		if ((server_socket_ = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) 
		{
			perror("Could not open socket");
			continue;
		}

		if (setsockopt(server_socket_, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int)) == -1)
		{
			perror("Socket setsockopt() failed");
			close(server_socket_);
			continue;
		}

		if (bind(server_socket_, p->ai_addr, p->ai_addrlen) == -1)
		{
			perror("Socket bind() failed");
			close(server_socket_);
			continue;
		}

		if (listen(server_socket_, 5) == -1)
		{
			perror("Socket listen() failed");
			close(server_socket_);
			continue;
		}

		break;
	}

	freeaddrinfo(res);

	if (p == NULL)
	{
    	fprintf(stderr, "Could not find a socket to bind to.\n");
        return 0;
    }
    return 1;
}

//----------------------------------------
// Incoming data handler spawns worker
//----------------------------------------
int ServerControlSocket::ReceiveAndRespond()
{   
    struct sockaddr_storage *client_addr;
	socklen_t sin_size = sizeof(struct sockaddr_storage);
	int client_socket;
	pthread_t worker_thread;
	
	client_addr = (sockaddr_storage *)malloc(sin_size);
	if ((client_socket = accept(server_socket_, (struct sockaddr *) client_addr, &sin_size)) == -1) 
	{
		free(client_addr);
		perror("Could not accept() connection");
        return 0;
	}

    ServerControlSocketWorker *worker = new ServerControlSocketWorker(this, client_socket);

	Lock();
	if (pthread_create(&worker_thread, NULL, HandleClient, worker) != 0) 
	{
		perror("Could not create a worker thread");
		free(client_addr);
		close(client_socket);
		return 0;
	}

	printf("\n(%d) accept_clients(): Waiting for thread setup to complete.\n", client_socket);
	while(!worker->SetupFinished())
        ConditionedWait();
	printf("(%d) accept_clients(): Woke up (setup complete).\n", client_socket);
    Unlock();

    return 1;
}

//----------------------------------------
// Accessor/helper functions
//----------------------------------------
int ServerControlSocket::fd()
{
    return server_socket_;
}

void ServerControlSocket::Lock()
{
    pthread_mutex_lock(&lock_);
}

void ServerControlSocket::SignalWorkerSetupFinished()
{
    pthread_cond_signal(&cv_setup_done_);
}

void ServerControlSocket::Unlock()
{
    pthread_mutex_unlock(&lock_);
}

void ServerControlSocket::ConditionedWait()
{
    pthread_cond_wait(&cv_setup_done_, &lock_);
}

//----------------------------------------
// Constructor
//----------------------------------------
ServerControlSocketWorker::ServerControlSocketWorker(ServerControlSocket *parent, int client_socket)
{
    parent_ = parent;
    client_socket_ = client_socket;
}

//----------------------------------------
// Accessor
//----------------------------------------
int ServerControlSocketWorker::SetupFinished() {
    if(finished_setup_)
        return 1;
    return 0;
}

//----------------------------------------
// Threaded worker with callback
//----------------------------------------
void ServerControlSocketWorker::HandleClient() {
	size_t nbytes;
	char buffer[100];

	printf("(%d) service_single_client(): Starting setup.\n", client_socket_);

	pthread_detach(pthread_self());
	
	finished_setup_ = 1;
	printf("(%d) service_single_client(): Setup complete.\n", client_socket_);

    parent_->Lock();
	parent_->SignalWorkerSetupFinished();
    parent_->Unlock();

	while(1)
	{
		nbytes = recv(client_socket_, buffer, sizeof(buffer), 0);
		if (nbytes == 0) {
			break;
            printf("done!\n");
		}
		else if (nbytes == -1)
		{
			perror("Socket recv() failed");
			close(client_socket_);
			pthread_exit(NULL);
		}
		else {
		    parent_->Lock();
            printf("got stuff\n");
            ControlPacket control;
            LineToControlPacket(buffer, &control);
            ControlPacket response = parent_->server_->ControlCallback(control);
            LinePacket lp = ControlPacketToLinePacket(&response);
            send(client_socket_, lp.packet_data, lp.packet_length, 0);
            DeleteLinePacket(&lp);
            DeleteControlPacket(&response);
            DeleteControlPacket(&control);
            parent_->Unlock();
		}
	}

	printf("(%d) service_single_client(): Disconnected.\n", client_socket_);
	close(client_socket_);
	pthread_exit(NULL);
}