//
//  NetCIMProtocol.h
//  CIM
//
//  Created by 董 林 on 11-10-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#ifndef _NET_CIM_PROTOCOL_H_
#define _NET_CIM_PROTOCOL_H_ 

#import "CIMBaseType.h"

///////////////////////////////////////////////////////////////////////////////
//
// Packet data structure
//

#define	NWPH_IDENTIFIER			0xc453			// The identifir code for packet header

#define	NWPH_COMPRESSION		0x01			// Compression
#define	NWPH_ENCRIPTION			0x02			// Encription
#define	NWPH_BEGINNING			0x04			// Not beginning packet
#define	NWPH_ENDING				0x08			// Not ending packet
#define	NWPH_USER_DATA			0x10			// User data present in data header?
#define	NWPH_COMMAND_RETURN		0x20			// This is a command return
#define	NWPH_INTERNAL_USE		0x40			// Internal use packet

#define	NWPH_SINGLEPACKET		(NWPH_BEGINNING | NWPH_ENDING)
#define	NWPH_PROCESSED			(NWPH_COMPRESSION | NWPH_ENCRIPTION)

typedef struct	_NETBASEHEADER
{
	WORD	wHeaderCRC;							// Header CRC count from follow this field to end of packet header (14 or 16 Bytes)
	WORD	wIdentifier;						// Identifier: 0xC453
	DWORD	dwSequence;							// Packet seguence number
	DWORD	dwLength;							// Data length, this length does not include this header and data header
	WORD	wCommand;							// Command
	BYTE	byComment;							// Parameter of command
	BYTE	byFlags;							// Packet information
                                                //	Bit 0 -- 1 = Compression
                                                //	Bit 1 -- 1 = Encription
                                                //	Bit 2 -- 1 = Beginning packet
                                                //	Bit 3 -- 1 = Ending packet
                                                //	Bit 4 -- 0 = No user data in data header
                                                //	Bit 5 -- 1 = This is a command return
                                                //	Bit 6 -- 1 = Internal use, not for data.
} NETBASEHEADER, *PNETBASEHEADER;

#define	NETBASEHEADER_SIZE		(sizeof(NETBASEHEADER))

typedef struct	_NETHEADERPACKET
{
	NETBASEHEADER	headerBase;					// Base data header
	DWORD64			dlwUserData;				// User Data
} NETHEADERPACKET, *PNETHEADERPACKET;

#define	NETHEADERPACKET_SIZE	(sizeof(NETHEADERPACKET))

typedef struct	_NETHEADERDATA
{
	DWORD	dwDataCRC;							// Data CRC, exist if dwLength != 0
	DWORD	dwDataSequence;						// Data seguence number, non-exist if Bit 2 = 1 and Bit 3 = 1 in byFlags
	DWORD	dwOriginalSize;						// Original data size, exist if Bit 0 != 0 or Bit 1 != 0 in byFlags
	DWORD	dwPackedSize;						// Data size after pack operation, exist if Bit 0 = 1 and Bit 1 = 1 in byFlags
} NETHEADERDATA, *PNETHEADERDATA;

#define	NETHEADERDATA_SIZE	(sizeof(NETHEADERDATA))

typedef struct	_NETHEADERCIM
{
	NETHEADERPACKET	headerPacket;
	NETHEADERDATA	headerData;
} NETHEADERCIM,*PNETHEADERCIM;

#define	NETHEADERCIM_SIZE	(sizeof(NETHEADERCIM))

#endif // _NET_CIM_PROTOCOL_H_