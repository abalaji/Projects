#include "tsc.h"

/* get_cycles() is the C interface to the tsc register.  It simply returns a 64-bit
 * value which represents the number of clock cycles which have elapsed since the CPU
 * was restarted.
 */
 
inline unsigned long long get_cycles (void)
{
	unsigned long eax, edx;

	rdtsc(eax,edx);
	
	return (long long)eax | (long long)edx << 32;
}

/* get_cycles32() returns only the lower 32 bits of the cycle counter.  This value
 * will roll over every ~4 billion cycles (about 10 seconds on a 400 MHz CPU).  It
 * is provided only because it is significantly faster than get_cycles() on an 
 * unoptimized binary, but only a couple of clock cycles faster if '-O' or better
 * optimization is applied. 
 */

inline unsigned long get_cycles32 (void)
{
	unsigned long eax, edx;

	rdtsc(eax,edx);
	return eax;
}

/* cycles_to_ns() can be called to convert a cycle count (typically a difference
 * between two calls to get_cycles()) into a floating point representation of the
 * number of nanoseconds which that many cycles represents.  This of course depends
 * on the clock frequency of the host CPU.
 *
 * On the first invocation of cycles_to_ns(), the clock frequency is determined.
 * Subsequent invocations will use this value rather than re-computing it.  For this
 * reason, cycles_to_ns() should not be called in a timed region of code because it
 * can have a variable delay.
 *
 * The clock frequency of the host CPU can be computed one of two ways.  
 * If FAST_FREQ_CALC is defined as non-zero, cycles_to_ns() will attempt to find
 * the CPU clock frequency by reading /proc/cpuinfo.  If this fails or if FAST_FREQ_CALC
 * is defined as zero, then the clock frequency will be measured by timing a delay
 * in both microseconds (via gettimeofday()) and clock cycles (using get_cycles()) and
 * computing the frequency.  In order to get decent accuracy this way, though, the delay
 * must be on the order of ~1 sec, hence it is much quicker to read the value from 
 * /proc/cpuinfo (besides, this value is computed more accurately *and* will not vary
 * from run to run on the same system!
 */

#define FAST_FREQ_CALC	1

double cycles_to_ns( unsigned long long cycles )
{
	static double ns_per_clock = 0;

	if( !ns_per_clock )
	{
		/* Try to find the clock frequency in /proc/cpuinfo */
	
		if( FAST_FREQ_CALC )
		{
			FILE *fp;
			char buf[81];
			int i;
			double freq;
			
			if( (fp = fopen("/proc/cpuinfo", "r")) != NULL )
			{	
				while( !feof(fp) )
				{	
					fgets(buf, 80, fp );
			
					/* Is this the right line? */
			
					if( !strncmp(buf, "cpu MHz", 7) )
					{
						/* Find the start of the frequency string */
					
						i=8;
						while( buf[i] < '0' || buf[i] > '9' )
							i++;
						
						/* Convert it to a double.  This represents
						 * the frequency in MHz.
						 */
						 					
						freq = atof(&buf[i]);
					
						/* Convert MHz into ns */
					
						ns_per_clock = 1000 / freq; 
					}		
				}
			
				fclose(fp);
			}		
		}
		
		/* If the above failed or FAST_FREQ_CALC==0, measure the freq directly */
		
		if( !ns_per_clock )
		{
			struct timeval time_start, time_stop;
			long cycle_start, cycle_stop;
			long cycle_count, ns_count;
			
			/* Here is the timed delay loop.  Experimentation shows that a 
			 * whopping 1 sec is necessary to achieve ~6 digits of precision.
			 */
		
			gettimeofday(&time_start, NULL);
			cycle_start = get_cycles32();
		
			usleep(1000000);
		
			cycle_stop = get_cycles32();
			gettimeofday(&time_stop, NULL);
		
			/* Compute the time of the loop in both ns and cycles */
			
			cycle_count = cycle_stop - cycle_start;
		
			ns_count = (time_stop.tv_sec - time_start.tv_sec)  * 1E9 + 
				   (time_stop.tv_usec - time_start.tv_usec) * 1E3;
			
			/* Find ns_per_clock */
			    
			ns_per_clock = (double)ns_count / (double)cycle_count;
		}
	}

	/* ns_per_clock has been computed above or on a previous invocation; 
	 * convert the clock cycle count into nanoseconds 
	 */

	return (double)cycles * ns_per_clock;
}

