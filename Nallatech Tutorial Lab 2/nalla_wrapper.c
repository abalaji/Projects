#include "nalla_wrapper.h"

/* Global Nallatech Variables */
char tempmessage[250];
unsigned int CardType;
FILE *bistlogfile = NULL;
LOCATE_HANDLE hLocate = NULL;
DIME_HANDLE hCard;
DIMETALK_HANDLE hTalk;


/* Actual Functions */
int DPRINT(FILE* logfile, char* Message)
{
    printf(Message);
    return 0;
}

int FPGA_release()
{
    DPRINT(bistlogfile,"Closing DIMETalk handle\n");
    DIMETalk_Close(hTalk);
    DIME_CloseCard(hCard); // Closes down the card.
    DIME_CloseLocate(hLocate);
    return 0;
}

int FPGA_config(char *ffile)
{
    // Load the devices in the network
    DPRINT(bistlogfile,"Loading memory test design files to test SRAM and SDRAM...\n");
    if (CardType != mbtH100PCIX)
    {
        DPRINT(bistlogfile,"This BIST only supports the H100 card, other card type detected - exiting\n");
        DIME_CloseCard(hCard);
        DIME_CloseLocate(hLocate);
        return 2;
    }
    else
    {
        //sprintf(tempmessage,"%s...","bennuey_pci_x_0.bit");
        DPRINT(bistlogfile,tempmessage);
        //Check card MDF to find out device type
        //if (  (DIME_ModuleStatus(hCard,(DIME_CardStatus(hCard,dinfNUMBERMODULES)-1),dinfDIMECODE)==0x13408033)   )
        //    ConfigResult = DIME_ConfigDevice(hCard,"h100_pcixm_memorytest_lx100.bit",(DIME_CardStatus(hCard,dinfNUMBERMODULES)-1),0,0,0);
        //if (  (DIME_ModuleStatus(hCard,(DIME_CardStatus(hCard,dinfNUMBERMODULES)-1),dinfDIMECODE)==0x13410033)   )
        //    ConfigResult = DIME_ConfigDevice(hCard,"h100_pcixm_memorytest_lx160.bit",(DIME_CardStatus(hCard,dinfNUMBERMODULES)-1),0,0,0);
        //
        //ConfigResult = DIME_ConfigDevice(hCard,"test.bit",(DIME_CardStatus(hCard,dinfNUMBERMODULES)-1),0,0,0);
        //if(DIME_ConfigOnBoardDevice(hCard,"h101_pcixm_0.bit",0) != dcfgOK_STATUS)
        if(DIME_ConfigOnBoardDevice(hCard,ffile,0) != dcfgOK_STATUS)
        {
            printf("ERROR\n");
	}

        //sprintf(tempmessage,"done, with configresult = %lx\n", ConfigResult);
        DPRINT(bistlogfile,tempmessage);
    }

    FPGA_reset2();
    hTalk = DIMETalk_Open(hCard, 1);

    return 0;
}

int FPGA_reset2()
{
    //Disable the resets
    //Check to see if the onboard fpga reset is supported on the particular card.
    if (DIME_CardResetStatus(hCard,drONBOARDFPGA,drONBOARDFPGA)==drCONTROLABLE)
        DIME_CardResetControl(hCard,drONBOARDFPGA, drDISABLE,0);

    DIME_CardResetControl(hCard,drSYSTEM, drDISABLE,0);
    Sleep(50);
    if (DIME_CardResetStatus(hCard,drONBOARDFPGA,drONBOARDFPGA)==drCONTROLABLE)
        DIME_CardResetControl(hCard,drONBOARDFPGA, drENABLE,0);
    DIME_CardResetControl(hCard,drSYSTEM, drENABLE,0);
    Sleep(50);
    if (DIME_CardResetStatus(hCard,drONBOARDFPGA,drONBOARDFPGA)==drCONTROLABLE)
        DIME_CardResetControl(hCard,drONBOARDFPGA, drDISABLE,0);
    DIME_CardResetControl(hCard,drSYSTEM, drDISABLE,0);
    DIME_CardResetControl(hCard,drINTERFACE, drTOGGLE,0);
    Sleep(50);
    DPRINT(bistlogfile,"Finished reset and configuration sequence...\n");
    return 0;
}

int FPGA_reset()
{
    DPRINT(bistlogfile,"Starting reset and configuration sequence...\n");

    // Check to see if the onboard reset is supported on the particular card.
    if (DIME_CardResetStatus(hCard,drONBOARDFPGA,drONBOARDFPGA)==drCONTROLABLE)
        DIME_CardResetControl(hCard,drONBOARDFPGA, drENABLE,0);
    // enable the ststem reset
    DIME_CardResetControl(hCard,drSYSTEM, drENABLE,0);

    // disable the system reset
    DIME_CardResetControl(hCard,drSYSTEM, drDISABLE,0);
    //Check to see if the onboard fpga reset is supported on the particular card.
    if (DIME_CardResetStatus(hCard,drONBOARDFPGA,drONBOARDFPGA)==drCONTROLABLE)
        DIME_CardResetControl(hCard,drONBOARDFPGA, drDISABLE,0);
    // toggle the interface reset
    DIME_CardResetControl(hCard,drINTERFACE, drTOGGLE,0);


    //Check to see if the onboard fpga reset is supported on the particular card.
    if (DIME_CardResetStatus(hCard,drONBOARDFPGA,drONBOARDFPGA)==drCONTROLABLE)
        DIME_CardResetControl(hCard,drONBOARDFPGA, drENABLE,0);
    // enable the ststem reset
    DIME_CardResetControl(hCard,drSYSTEM, drENABLE,0);
    return 0;
}

int FPGA_gethandle()
{
    SWMBInfo *pBoardInfo;
    unsigned int iftype = dlPCI;
    unsigned int ErrorNum=0,NumOfCards,LoopCntr;//,ConfigResult;
    unsigned int SerialNum=0;
    unsigned int CardNum=1;
    char ErrorString[1000];

    pBoardInfo = (SWMBInfo *)DIME_SystemStatusPtr(0,dinfDIME_SWMBTS);

    // Call the function to locate all Nallatech cards on the PCI interface.
    if( (hLocate = DIME_LocateCard(iftype,mbtALL,NULL,dldrDEFAULT,dlDEFAULT)) == NULL)
    {// Error hLocate NULL
        // Print the error then terminate the program
        //DIME_GetError(NULL,(DWORD *)ErrorNum,ErrorString);
        sprintf(tempmessage,"Error Number %d\n", ErrorNum);
        DPRINT(bistlogfile,tempmessage);
        sprintf(tempmessage,"%s\n",ErrorString);
        DPRINT(bistlogfile,tempmessage);
        sprintf(tempmessage,"\nPress return to terminate the application.\n");
        DPRINT(bistlogfile,tempmessage);
        getchar();
        exit(1);
    }

    // Determine how many Nallatech cards have been found.
    NumOfCards = DIME_LocateStatus(hLocate,0,dlNUMCARDS);
    char tempmessage[250];

    printf("Starting H100 tests for BIST\n");

    DPRINT(bistlogfile,"#######################################\n");
    DPRINT(bistlogfile,"H100 Built In Self Test Executable...\n");
    DPRINT(bistlogfile,"#######################################\n");

    pBoardInfo = (SWMBInfo *)DIME_SystemStatusPtr(0,dinfDIME_SWMBTS);

    // Call the function to locate all Nallatech cards on the PCI interface.
    if( (hLocate = DIME_LocateCard(iftype,mbtALL,NULL,dldrDEFAULT,dlDEFAULT)) == NULL)
    {// Error hLocate NULL
        // Print the error then terminate the program
        //DIME_GetError(NULL,(DWORD *)ErrorNum,ErrorString);
        sprintf(tempmessage,"Error Number %d\n", ErrorNum);
        DPRINT(bistlogfile,tempmessage);
        sprintf(tempmessage,"%s\n",ErrorString);
        DPRINT(bistlogfile,tempmessage);
        sprintf(tempmessage,"\nPress return to terminate the application.\n");
        DPRINT(bistlogfile,tempmessage);
        getchar();
        exit(1);
    }

    // Determine how many Nallatech cards have been found.
    NumOfCards = DIME_LocateStatus(hLocate,0,dlNUMCARDS);
    sprintf(tempmessage,"%d Nallatech card(s) found.\n", NumOfCards);
    DPRINT(bistlogfile,tempmessage);

    // Get the details for each card detected.
    for (LoopCntr=1; LoopCntr<=NumOfCards; LoopCntr++)
    {
        unsigned int type = DIME_LocateStatus(hLocate,LoopCntr,dlMBTYPE);
        unsigned int typecount, found;
        sprintf(tempmessage,"Details of card number %d, of %d:\n",LoopCntr,NumOfCards);
        DPRINT(bistlogfile,tempmessage);
        typecount=found=0;
        while (typecount<pBoardInfo->NumTypes && !found)
        {
            if (pBoardInfo->pCardInfo[typecount].MotherBoardType==type)
            {
                found=1;
                sprintf(tempmessage,"\tCard Description : %s\n",pBoardInfo->pCardInfo[typecount].MotherBoardDesc);
                DPRINT(bistlogfile,tempmessage);
            }
            typecount++;
        }
        if (!found)
        {
            sprintf(tempmessage,"\tThis is an unrecognised card. Driver %s\n",(char*)DIME_LocateStatusPtr(hLocate,LoopCntr,dlDESCRIPTION));
            DPRINT(bistlogfile,tempmessage);
        }
    }

    // Open up the first card found. To open the nth card found simple change the second argument to n.
    hCard = DIME_OpenCard(hLocate,CardNum,dccOPEN_DEFAULT); //opens up card 1 with default flags
    if (hCard == NULL) //check to see if the open worked.
    {
        DPRINT(bistlogfile,"Card Number One failed to open.\n");
        DIME_CloseLocate(hLocate);
        DPRINT(bistlogfile,"\nPress return to terminate the application.\n");
        getchar();
        //return(1);
	exit(-1);
    }

    // Determine what type of card type it is.
    CardType = DIME_CardStatus(hCard,dinfMOTHERBOARDTYPE);
    SerialNum = DIME_CardStatus(hCard,dinfSERIALNUMBER);
    sprintf(tempmessage,"\tCard Serial Number : %x\n",SerialNum);
    DPRINT(bistlogfile,tempmessage);
    sprintf(tempmessage,"\tCard Firmware Version : %lx\n",DIME_CardStatus(hCard,dinfFIRMWAREVER));
    DPRINT(bistlogfile,tempmessage);

    {
        unsigned int SramIdelayCal=0;
        SramIdelayCal = DIME_CardStatus(hCard,dinfIF_SRAM_IDELAY_STATUS);
        sprintf(tempmessage,"Sram PCIX Idelay Status %x\n",SramIdelayCal);
        DPRINT(bistlogfile,tempmessage);
    }


    // If it's a BenNUEY-PCIX or a BenNUEY-PCI104-v4 we need to set the oscilators to programmable
    if((CardType==mbtTHEBENNUEYPCIX) || (CardType==mbtTHEBENNUEYPCI104V4) || (CardType==mbtH100PCIX))
    {
        DPRINT(bistlogfile,"Setting the clocks to the programmable oscillators\n");
        fflush(bistlogfile);
        DIME_OscillatorControl(hCard,1,oscOSCSELECT,oscPROGOSC);
        DIME_OscillatorControl(hCard,2,oscOSCSELECT,oscPROGOSC);
        DIME_OscillatorControl(hCard,3,oscOSCSELECT,oscPROGOSC);
    }
    return 0;
}


int FPGA_setclocks(double CLKA, double CLKB, double CLKC)
{
    double ActualFreq;
	
    // Set up the oscilators frequencies
    DIME_SetOscillatorFrequency(hCard,1,CLKA,&ActualFreq);
    sprintf(tempmessage,"Clock A set to %f\n",ActualFreq);
    DPRINT(bistlogfile,tempmessage);
    DIME_SetOscillatorFrequency(hCard,2,CLKB,&ActualFreq);
    sprintf(tempmessage,"Clock B set to %f\n",ActualFreq);
    DPRINT(bistlogfile,tempmessage);
    DIME_SetOscillatorFrequency(hCard,3,CLKC,&ActualFreq);
    sprintf(tempmessage,"Clock C set to %f\n",ActualFreq);
    DPRINT(bistlogfile,tempmessage);
    return 0;
}

void FPGA_init(double a, double b, double c)
{
  FPGA_gethandle();
  FPGA_setclocks(a,b,c);
  FPGA_reset();
}


void FPGA_write(DWORD * az, int size, int addr, int node, int timeout)
{
  DIMETalk_Write(hTalk, az, size, addr, node, timeout);
}

void FPGA_read(DWORD *az, int size, int addr, int node, int timeout)
{
  DIMETalk_Read(hTalk, az, size, addr, node, timeout);
}

