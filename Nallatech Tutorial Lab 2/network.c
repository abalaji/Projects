#include <dimesdl.h>
#include <dimetalk.h>
#include "network.h"

DWORD nodeaddr[NUMNODES] = {
   2/* block_ram_0( BlockRam Node )*/
  ,1/* ddr2sram_if_h100_0( DDR2 SRAM 32 Memory Node For Use With H101-E & H101-M )*/
  ,3/* memory_map_0( Simple Memory Map Node )*/
};

char *devicefiles[NUMDEVICES] = {
   "C:/Documents and Settings/Adam/My Documents/Lab Work/Nalla_Designs/sram_blockram/source/h101_pcixm_0/h101_pcixm_0.bit" /* h101_pcixm_0*/
};

DWORD deviceinfo[NUMDEVICES][2] = {
   {-1,0}/* h101_pcixm_0*/
};
