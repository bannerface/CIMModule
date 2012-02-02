//
//  CIMNetCommand.h
//  CIM
//
//  Created by 董 林 on 11-11-1.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#ifndef CIM_CIMNetCommand_h
#define CIM_CIMNetCommand_h

typedef struct{
    UInt16  wCommand;           // Command
    UInt8   byComment;          // Parameter of command
    UInt8   byFlags;            // Packet information
                                //	Bit 0 -- 1 = Compression
                                //	Bit 1 -- 1 = Encription
                                //	Bit 2 -- 1 = Beginning packet
                                //	Bit 3 -- 1 = Ending packet
                                //	Bit 4 -- 0 = No user data in data header
                                //	Bit 5 -- 1 = This is a command return
                                //	Bit 6 -- 1 = Internal use, not for data.
                                //  Bit 7 -- 1 = Caller keep this data buffer
}NETCOMMAND, PNETCOMMAND;

#define NWPH_CALLER_DATA        0x80

#endif
