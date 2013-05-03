#ifndef __MD5_H__
#define __MD5_H__

#include <stdint.h>

void md5_hash(uint8_t *message, uint32_t len, uint32_t *hash);

#endif