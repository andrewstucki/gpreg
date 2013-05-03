#include <iostream>
#include <pthread.h>
#include <signal.h>
#include <poll.h>

#include <arpa/inet.h>

#include "server.h"
#include "common.h"
#include "protocol.h"
#include "address.h"
#include "udp_socket.h"
#include "signup_form.pb.h"

//----------------------------------------
// Constructor and Destructor
//----------------------------------------
RegistrationServer::RegistrationServer() : control_socket_(NULL), udp_socket_(NULL)
{
    control_socket_ = new ServerControlSocket((char *)"*", SOCK, this);
    udp_socket_ = new UDPSocket(PING_PORT_NUMBER);
}

RegistrationServer::~RegistrationServer()
{
    if (udp_socket_)
        delete udp_socket_;
    if (control_socket_)
        delete control_socket_;        
}

//----------------------------------------
// Start/Stop routines
//----------------------------------------
void RegistrationServer::Listen()
{
    finish_thread_ = 0;
    pthread_create(&listen_thread_, NULL, RunLoop, this);
}

void RegistrationServer::RunLoop()
{
    struct pollfd pollitems[] = {
        {control_socket_->fd(), POLLIN, 0},
        {udp_socket_->fd(), POLLIN, 0}
    };
    
    while(!finish_thread_)
    {
      if(poll(pollitems, 2, PING_INTERVAL) == -1) break;
      
      if (pollitems[0].revents & POLLIN) {
          if(HandleControl() == -1) break;
      }
      
      if (pollitems[1].revents & POLLIN) {
          if(HandleBeacon() == -1) break;
      }
    }
    finish_thread_ = 0;
}

void RegistrationServer::Stop()
{
    finish_thread_ = 1;
    pthread_join(listen_thread_, NULL);
}

//----------------------------------------
// ControlPacket/Protobuf Helpers
//----------------------------------------
bool RegistrationServer::ParseControlRequest(::google::protobuf::MessageLite *request, ControlPacket *control)
{
    char *data = ReadControlPacketData(*control, (char *)"test");
    if (data == NULL)
    {
        return false;
    }
    return request->ParseFromArray(data, control->data_length);
}

ControlPacket RegistrationServer::CreateControlResponse(::google::protobuf::MessageLite *response, int type)
{
    ControlPacket control = CreateControlPacket(type, (char *)response->SerializeAsString().c_str(), response->ByteSize(), (char*)"test");
    return control;
}

//----------------------------------------
// Packet Handlers
//----------------------------------------
int RegistrationServer::HandleBeacon()
{
    NetworkAddress address;
    BeaconPacket beacon;
    udp_socket_->Receive(&beacon, &address);

    if(IsBeaconValid(beacon) && (beacon.header.type == BEACON_REQ)) {
        BeaconPacket beacon = CreateBeaconPacket(BEACON_REP, PASSWORD_ENABLED, SOCK);
        udp_socket_->Send(&beacon, &address);
    }
    return 1;
}

int RegistrationServer::HandleControl()
{
    printf("found data on control port\n");
    control_socket_->ReceiveAndRespond();
    return 1;
}

//----------------------------------------
// Callback for Control data
//----------------------------------------
ControlPacket RegistrationServer::ControlCallback(ControlPacket control)
{
    if (IsControlValid(control))
    {
        switch (control.header.command)
        {
            case SIGNUP_REQ: return Signup(&control);
                break;
            case SELECT_REQ: return Select(&control);
                break;
            case LIST_REQ: return List(&control);
                break;
            case SYNC_REQ: return Sync(&control);
                break;
            default: return Invalid();
                break;
        }
    }
    return ControlPacket();
}

//----------------------------------------
// Control RPC functions
//----------------------------------------
ControlPacket RegistrationServer::Signup(ControlPacket *control)
{
    SignupRequest request;
    ParseControlRequest(&request, control);
    if (&request == NULL)
        printf("NULL");
    std::cout << "data: " << request.name() << std::endl;
    for (::google::protobuf::RepeatedPtrField<SignupRequest_FormEntry const>::iterator it = request.entry().begin(); it != request.entry().end(); it++) {
            for (int j = 0; j < (*it).value_size(); j++) {
                std::cout << "form_entry: " << (*it).name() << ", " << (*it).value(j) << std::endl;   
            }
        }
    
    SignupResponse response;
    response.set_response("woohoo!");
    request.Clear();
    
    return CreateControlResponse(&response, SIGNUP_REP);
}

ControlPacket RegistrationServer::Select(ControlPacket *control)
{
    FormRequest request;
    ParseControlRequest(&request, control);
    return ControlPacket();
}

ControlPacket RegistrationServer::List(ControlPacket *control)
{
    ListRequest request;
    if(ParseControlRequest(&request, control))
    {
        ListResponse response;
        response.add_id(1);
        response.add_id(2);
        
        return CreateControlResponse(&response, LIST_REP);
    }
    else
        return Invalid();
}

ControlPacket RegistrationServer::Invalid()
{
    return CreateControlPacket(PACK_INV, NULL, 0);
}

ControlPacket RegistrationServer::Sync(ControlPacket *control)
{
    // SyncRequest request;
    // ParseControlRequest(&request, control)
    return ControlPacket();
}

///////////////////////////////////////////
/// test
///////////////////////////////////////////

/*
RegistrationServer *reg;

void inter(int s){
    reg->Stop();
    delete reg;
    exit(1);
}

int
main(void)
{
    try {
        reg = new RegistrationServer();
        reg->Listen();
        while(true){sleep(100);}
    } catch (SocketError &error) {
        std::cout << error.what() << std::endl;
    }
}
*/