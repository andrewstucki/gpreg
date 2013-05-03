#include "common.h"

#include <sys/time.h>

uint64_t clock_time(void)
{
#if defined (__WINDOWS__)
  FILETIME ft;
  GetSystemTimeAsFileTime (&ft);
  return s_filetime_to_msec (&ft);
#else
  struct timeval tv;
  gettimeofday (&tv, NULL);
  return (int64_t) ((int64_t) tv.tv_sec * 1000 + (int64_t) tv.tv_usec / 1000);
#endif
}