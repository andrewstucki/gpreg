#include <string.h>

#define SWAP(a, b) ((a) ^= (b), (b) ^= (a), (a) ^= (b))
void rc4_crypt(char *msg, const char *key)
{
    unsigned char sbox[256];
    unsigned char skey[256];
    unsigned char k;
    int m,i=0,j=0,n=0;
    
    size_t key_len = strlen(key);
    size_t msg_len = strlen(msg);
    
    memset(sbox, 0, 256);
    memset(skey, 0, 256);
    
    for(m = 0; m < 256; m++)
    {
        *(skey + m) = *(key + (m % key_len));
        *(sbox + m) = m;
    }
    
    for(m = 0; m < 256; m++)
    {
        n = (n + *(sbox+m) + *(skey +m)) & 0xFF;
        SWAP(*(sbox+m),*(sbox+n));
    }
    
    for(m = 0; m < msg_len; m++)
    {
        i = (i + 1) & 0xFF;
        j = (j + *(sbox + i)) & 0xFF;
        SWAP(*(sbox+i), *(sbox+j));
        k = *(sbox + ((*(sbox + i) + *(sbox + j)) & 0xFF));
        if (k == *(msg + m)) k = 0;
        *(msg + m) ^= k;
    }
}
