#ifndef __COMMON_H__
#define __COMMON_H__

#include <stdint.h>

#define SOCK 54320
#define PING_PORT_NUMBER 9966
#define PING_RESP_NUMBER 9998
#define PING_MSG_SIZE    1
#define PING_INTERVAL    10000

uint64_t clock_time(void);

#endif //__COMMON_H__