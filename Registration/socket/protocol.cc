#include <stdlib.h>
#include <string.h>

#include "common.h"
#include "md5.h"
#include "rc4.h"
#include "protocol.h"

BeaconPacket CreateBeaconPacket(char type, char flags, uint16_t port)
{
    BeaconPacket beacon;
    memcpy(beacon.header.protocol, BEACON_PROTOCOL, sizeof(BEACON_PROTOCOL));
    beacon.header.type = type;
    beacon.header.timestamp =  clock_time();
    beacon.data.flags = flags;
    beacon.data.port = port;

    uint32_t hash[4];
    md5_hash((uint8_t *)&beacon.header, sizeof(beacon.header), hash);

    memcpy(beacon.hash, hash, sizeof(hash));
    
    return beacon;
}

bool IsBeaconValid(BeaconPacket beacon)
{
    if(strcmp(beacon.header.protocol, BEACON_PROTOCOL))
        return false;

    uint32_t hash[4];
    md5_hash((uint8_t *)&beacon.header, sizeof(beacon.header), hash);
    
    if ((beacon.hash[0] == hash[0]) && (beacon.hash[1] == hash[1]) && (beacon.hash[2] == hash[2]) && (beacon.hash[3] == hash[3]))
        return true;
    return false;
}

ControlPacket CreateControlPacket(char command, char* data, uint32_t data_length, const char* password, char flags)
{
    ControlPacket control;
    memcpy(control.header.protocol, CONTROL_PROTOCOL, sizeof(CONTROL_PROTOCOL));
    control.header.command = command;
    control.header.flags = flags;
    control.header.timestamp = clock_time();
    control.header.command = command;
    control.data_length = data_length;    
    control.data = (char *)malloc(control.data_length);
    
    if(password && (strcmp(password, "") != 0)) {
        rc4_crypt(data, password);
        control.header.flags |= PASSWORD_ENABLED; 
    }
    memcpy(control.data, data, control.data_length);
    
    uint32_t hash[4];
    md5_hash((uint8_t *)&control.header, sizeof(control.header), hash);

    memcpy(control.hash, hash, sizeof(hash));

    return control;
}

void DeleteControlPacket(ControlPacket *control)
{
    free(control->data);
}

bool IsControlValid(ControlPacket control)
{
    if(strcmp(control.header.protocol, CONTROL_PROTOCOL))
        return false;
    if(control.header.command == PACK_INV)
        return false;

    uint32_t hash[4];
    md5_hash((uint8_t *)&control.header, sizeof(control.header), hash);
    
    if ((control.hash[0] == hash[0]) && (control.hash[1] == hash[1]) && (control.hash[2] == hash[2]) && (control.hash[3] == hash[3]))
        return true;
    return false;
}

void LineToControlPacket(void *message, ControlPacket *control)
{
    memcpy(control, message, offsetof(ControlPacket, data));
    control->data = (char *)malloc(control->data_length);
    memcpy(control->data, (char *)message+offsetof(ControlPacket, data), control->data_length);
}

LinePacket ControlPacketToLinePacket(ControlPacket *control)
{
    LinePacket lp;
    lp.packet_length = control->data_length+offsetof(ControlPacket, data);
    lp.packet_data = malloc(lp.packet_length);
    memcpy(lp.packet_data, (void *)control, offsetof(ControlPacket, data));
    memcpy((char *)lp.packet_data+offsetof(ControlPacket, data), (void *)control->data, control->data_length);
    return lp;
}

void DeleteLinePacket(LinePacket *line_packet)
{
    free(line_packet->packet_data);
}

char * ReadControlPacketData(ControlPacket control, const char *password)
{
    if (password && (strcmp(password, "") != 0))
    {
        if (control.header.flags & PASSWORD_ENABLED)
            rc4_crypt(control.data, password);
        else
            return NULL;
    }
    return control.data;
}