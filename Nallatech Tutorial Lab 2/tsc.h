/*
 * tsr.h
 *
 * i386 architecture clock cycle counter
 */
#ifndef _TSR_H
#define _TSR_H

#include <sys/time.h>
#include <unistd.h> 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* If FAST_FREQ_CALC is defined as non-zero, cycles_to_ns will attempt to find
 * the CPU clock frequency by reading /proc/cpuinfo.  If this fails or if FAST_FREQ_CALC
 * is defined as zero, then the clock frequency will be measured by timing a delay
 * in both microseconds (via gettimeofday()) and clock cycles (using get_cycles) and
 * computing the frequency.  In order to get decent accuracy this way, though, the delay
 * must be on the order of ~1 sec, hence it is much quicker to read the value from 
 * /proc/cpuinfo (besides, this value is computed more accurately *and* will not vary
 * from run to run on the same system!
 */

#define FAST_FREQ_CALC	1

/* GNU inline assebler magic to read the tsc counter.  
 * Requires a Pentium Pro or better. 
 */

#define rdtsc(low,high) \
     __asm__ __volatile__("rdtsc" : "=a" (low), "=d" (high))

inline unsigned long long get_cycles (void);
inline unsigned long get_cycles32 (void);
double cycles_to_ns( unsigned long long cycles );

#endif
