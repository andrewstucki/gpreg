#ifndef __PROTOCOL_H__
#define __PROTOCOL_H__

#include <stdint.h>
#include <stddef.h>

enum ProtocolFlags {
    PASSWORD_ENABLED = 0x01
};

#define BEACON_PROTOCOL     "GPR"

enum BeaconTypes {
    BEACON_REQ = 0x01,
    BEACON_REP = 0x02
};

typedef struct {
    struct {
        char protocol [4];
        char type;
        uint64_t timestamp;
    } header;
    uint32_t hash [4];        
    struct {
        char flags;
        uint16_t port;
    } data;
} BeaconPacket;

BeaconPacket CreateBeaconPacket(char type, char flags = 0, uint16_t port = 0);
bool IsBeaconValid(BeaconPacket beacon);

#define CONTROL_PROTOCOL    "CON"

enum ControlCommands {
    SIGNUP_REQ = 0x01,
    SIGNUP_REP = 0x02,
    SELECT_REQ = 0x03,
    SELECT_REP = 0x04,
    LIST_REQ   = 0x05,
    LIST_REP   = 0x06,
    SYNC_REQ   = 0x07,
    SYNC_REP   = 0x08,
    PACK_INV   = 0x09
};

typedef struct {
    struct {
        char protocol [4];
        char command;
        char flags;
        uint64_t timestamp;
    } header;
    uint32_t hash [4];
    uint32_t data_length;
    char *data;
} ControlPacket;

typedef struct {
    size_t packet_length;
    void *packet_data;
} LinePacket;

ControlPacket CreateControlPacket(char command, char* data, uint32_t data_length, const char* password = NULL, char flags = 0);
void LineToControlPacket(void *message, ControlPacket *control);
LinePacket ControlPacketToLinePacket(ControlPacket *control);
void DeleteLinePacket(LinePacket *line_packet);
void DeleteControlPacket(ControlPacket *control);
char * ReadControlPacketData(ControlPacket control, const char *password = NULL);
bool IsControlValid(ControlPacket control);

#endif //__PROTOCOL_H__