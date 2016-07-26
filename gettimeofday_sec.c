#include <time.h>
#include <sys/time.h>

double gettimeofday_sec();
double gettimeofday_sec() {
  struct timeval tv;
  gettimeofday(&tv, NULL);
  return tv.tv_sec + (double)tv.tv_usec*1e-6;
}
