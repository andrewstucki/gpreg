#include <arpa/inet.h>

#include <poll.h>

#include "client.h"
#include "common.h"
#include "protocol.h"
#include "address.h"
#include "udp_socket.h"
#include "signup_form.pb.h"

#include "signup_form.pb.h"

#define POLL_TIME 10000

//----------------------------------------
// Constructor and Destructor
//----------------------------------------
RegistrationClient::RegistrationClient() : control_socket_(NULL), udp_socket_(NULL)
{
    udp_socket_ = new UDPSocket(PING_RESP_NUMBER+rand()*20);
}

RegistrationClient::~RegistrationClient()
{
    if (udp_socket_)
        delete udp_socket_;
    if (control_socket_)
        delete control_socket_;
}

//----------------------------------------
// RPC Functions
//----------------------------------------
bool RegistrationClient::Signup()
{
    bool valid = false;
    SignupRequest request;
    request.set_name("Andrew");
    SignupRequest::FormEntry *form_entry = request.add_entry();
    form_entry->set_name("Patrick Gray");
    form_entry->add_value("Stucki");
    form_entry->add_value("Bleh");
    printf("sending request\n");
    SendControlRequest(&request, SIGNUP_REQ);
    ControlPacket control;
    control_socket_->Receive(&control);

    if (IsControlValid(control) && (control.header.command == SIGNUP_REP))
    {
        valid = true;
        SignupResponse response;
        ParseControlResponse(&response, &control);        
        printf("%s\n", response.response().c_str());
    }
    DeleteControlPacket(&control);
    return valid;
}

bool RegistrationClient::Select()
{
    return true;
}

bool RegistrationClient::List(std::string username)
{
    bool valid = false;
    ListRequest request;
    request.set_username(username);
    SendControlRequest(&request, LIST_REQ);
    ControlPacket control;
    control_socket_->Receive(&control);
    if (IsControlValid(control) && (control.header.command == LIST_REP))
    {
        printf("Valid control response\n");
        valid = true;
        ListResponse response;
        ParseControlResponse(&response, &control);
        for (::google::protobuf::RepeatedField<uint32_t>::const_iterator it = response.id().begin(); it != response.id().end(); it++) {
            forms.push_back(*it);
        }
    }
    DeleteControlPacket(&control);
    return valid;
}

bool RegistrationClient::Sync()
{
    return true;
}

//----------------------------------------
// Helpers
//----------------------------------------
void RegistrationClient::ParseControlResponse(::google::protobuf::MessageLite *response, ControlPacket *control)
{
    char *data = ReadControlPacketData(*control, connected_server_->password.c_str());
    response->ParseFromArray(data, control->data_length);
}

void RegistrationClient::SendControlRequest(::google::protobuf::MessageLite *request, int type)
{
    ControlPacket control = CreateControlPacket(type, (char *)request->SerializeAsString().c_str(), request->ByteSize(), connected_server_->password.c_str());
    control_socket_->Send(&control);
    DeleteControlPacket(&control);
}

//----------------------------------------
// Packet Handler
//----------------------------------------
int RegistrationClient::HandleBeacon()
{
    BeaconPacket beacon;
    NetworkAddress server_address;
    udp_socket_->Receive(&beacon, &server_address);
    if(IsBeaconValid(beacon) && (beacon.header.type == BEACON_REP))
    {
        ServerInfo info;
        info.address = inet_ntoa(server_address.sin_addr);
        info.port = beacon.data.port;
        info.flags = beacon.data.flags;
        serverInfo.push_back(info);
    }
    return 1;
}

//----------------------------------------
// Discovery Loop
//----------------------------------------
void RegistrationClient::Discover(int poll_time)
{
  int be = 0;
  struct pollfd pollitems[] = {
    {udp_socket_->fd(), POLLIN, 0}
  };
  uint64_t ping_at = clock_time();
  uint64_t initial_time = ping_at;
  while(poll_time > (ping_at-initial_time))
  {
    long timeout = (long)(ping_at-clock_time());
    if (timeout < 0) timeout = 0;
    if (poll(pollitems, 1, (int)timeout) == -1)
      break;
    if (pollitems[0].revents & POLLIN) {
      if (HandleBeacon()) be = 1; //remove the break so that we can poll with a set time
    }
    if (clock_time() >= ping_at) {
      BeaconPacket beacon = CreateBeaconPacket(BEACON_REQ, PASSWORD_ENABLED, PING_PORT_NUMBER);
      NetworkAddress broadcast = CreateBroadcastAddress(PING_PORT_NUMBER);
      //reduce the following to just Send, remove be
      //and split out everything else to a separate function
      udp_socket_->Send(&beacon, &broadcast);
//      else {
//          printf("signing up!\n");
//          Signup();
//      }
      ping_at = clock_time() + 1000;
    }
  }
}

bool RegistrationClient::Connect(ServerInfo *server)
{
    connected_server_ = server;
    printf("Address: %s, Port: %d, Password: %s\n",server->address, server->port
           , server->password.c_str());
    control_socket_ = new ClientControlSocket(connected_server_->address,connected_server_->port);
    return true;
}

bool RegistrationClient::Disconnect()
{
    connected_server_ = NULL;
    if (control_socket_)
    {
        delete control_socket_;
    }
    return true;
}

//----------------------------------------
// Test
//----------------------------------------
/*
int
main(void)
{
    RegistrationClient *client = new RegistrationClient();
    client->Discover(POLL_TIME); //change POLL_TIME to be variable
    delete client;
    return 1;
}
*/