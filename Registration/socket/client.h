#ifndef __CLIENT_H__
#define __CLIENT_H__

#include <vector>
#include <string>
#include <stdint.h>

#include <google/protobuf/message_lite.h>

#include "udp_socket.h"
#include "client_control_socket.h"
#include "address.h"

typedef struct {
    char *address;
    uint16_t port;
    char flags;
    std::string password;
} ServerInfo;

class RegistrationClient {
  public:
      RegistrationClient();
      ~RegistrationClient();
      bool Signup();
      bool Select();
      bool List(std::string username);
      bool Sync();
      void Discover(int poll_time);
      bool Connect(ServerInfo *server);
      bool Disconnect();
      std::vector<ServerInfo> serverInfo;
      std::vector<uint32_t> forms;
  private:
      ClientControlSocket *control_socket_;
      UDPSocket *udp_socket_;
      ServerInfo *connected_server_;
      int HandleBeacon();
      int HandleControl();
      void ParseControlResponse(::google::protobuf::MessageLite *response, ControlPacket *control);
      void SendControlRequest(::google::protobuf::MessageLite *request, int type);
};

#endif //__CLIENT_H__