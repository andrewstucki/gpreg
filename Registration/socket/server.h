#ifndef __SERVER_H__
#define __SERVER_H__

#include <stdint.h>

#include <google/protobuf/message_lite.h>

#include "udp_socket.h"
#include "server_control_socket.h"
#include "protocol.h"

class RegistrationServer;
class ServerControlSocket;

class RegistrationServer {
  public:
      RegistrationServer();
      ~RegistrationServer();
      void Listen();
      void Stop();
      ControlPacket Signup(ControlPacket *control);
      ControlPacket Select(ControlPacket *control);
      ControlPacket List(ControlPacket *control);
      ControlPacket Invalid();
      ControlPacket Sync(ControlPacket *control);
      ControlPacket ControlCallback(ControlPacket control);
  private:
      ServerControlSocket *control_socket_;
      UDPSocket *udp_socket_;

      pthread_t listen_thread_;
      int finish_thread_;

      void RunLoop();

      int HandleBeacon();
      int HandleControl();

      bool ParseControlRequest(::google::protobuf::MessageLite *request, ControlPacket *control);
      ControlPacket CreateControlResponse(::google::protobuf::MessageLite *response, int type);

      static void * RunLoop(void * This) {((RegistrationServer *)This)->RunLoop(); return NULL;}
};

#endif //__SERVER_H__