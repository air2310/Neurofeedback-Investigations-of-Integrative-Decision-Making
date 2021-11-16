/**********************************************************
							  
  Get ip address of a computer by the name.
  Based on the article contributed by Jeff Lundgren
  (http://www.codeguru.com/network/local_hostname.shtml) and
  tcp_udp_ip toolbox by Peter Rydesäter (Peter.Rydesater@mh.se)

  Notes for Linux implementation
  Compile this with:
  
  mex -O getip.c
  
  Notes for Windows implementation
  
  Compile this with:
  mex -O getip.c ws2_32.lib -DWIN32

                                                  */
/*
  Copyright (C) Peter Volegov 2002, Albuquerque, NM, USA
  
  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; 

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
    
  **********************************************************/
    
#include "mex.h"

#ifdef WIN32
//Windows include files
#include <winsock2.h>

#else
//Linux include files
#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#endif


void mexFunction(
	int nlhs,              // Number of left hand side (output) arguments
	mxArray *plhs[],       // Array of left hand side arguments
	int nrhs,              // Number of right hand side (input) arguments
	const mxArray *prhs[]  // Array of right hand side arguments
)
{
	char szHostName[128];
	char **str, *pTmp, *pAddr;
	int i, n, nip, status;
	struct hostent * pHost;


#ifdef WIN32
	// Initiate use of WS2_32.DLL
	WORD wVersionRequested;
	WSADATA wsaData;
	int wsa_err;    
	wVersionRequested = MAKEWORD( 2, 0 );
	wsa_err = WSAStartup( wVersionRequested, &wsaData );
	if (wsa_err)
	    mexErrMsgTxt("Error starting WINSOCK32");
#endif
 
	szHostName[0] = '\0';
	if(nrhs < 1)
	{
		if(gethostname(szHostName, sizeof(szHostName)) != 0)
			mexErrMsgTxt("Can not get host name");
	}
	else
	{
		if(mxIsChar(prhs[0]))
		{
			n = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;
			if(n < sizeof(szHostName))
			{
				status = mxGetString(prhs[0], szHostName, n);
				if (status != 0)
					mexErrMsgTxt("Could not convert HostName string");
			}
			else
				mexErrMsgTxt("HostName string is too long");
		}
		else
			mexErrMsgTxt("HostName should be a string");
	}

	if(szHostName[0] != '\0')
	{
		// Get host info
		pHost = gethostbyname(szHostName);
		
		nip = 0;
		str = NULL;
		for(i = 0; pHost != NULL && pHost->h_addr_list[i] != NULL; i++)
		{
			//Convert address to text string
			pAddr = inet_ntoa(*(struct in_addr *)pHost->h_addr_list[i]);

			//Allocate memory to hold IP address string
			pTmp = mxRealloc(str, sizeof(char*)*(nip+1));
			if(pTmp == NULL)
			{
				mexWarnMsgTxt("Can not allocate memory to hold IP address");
				break;
			}
			else
			{
				str = (char **)pTmp;
			}
			n = (int)strlen(pAddr);
			str[i] = (char *)mxCalloc(n+1, sizeof(char));

			//Copy IP string
			memcpy(str[i], pAddr, n+1);
			nip = nip+1;

		}
		plhs[0] = mxCreateCharMatrixFromStrings(nip, (const char **)str);

		//Free allocated memory
		for(i = 0; i < nip; i++) mxFree(str[i]);
		mxFree(str);
	}
	else
	{
		plhs[0] = mxCreateString(NULL);
	}

	if(nlhs > 1)
	{
		plhs[1] = mxCreateString(szHostName);
	}

#ifdef WIN32
	// Terminate use of the WS2_32.DLL
    WSACleanup();
#endif

}
