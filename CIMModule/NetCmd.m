//
//  NetCmd.m
//  NetCmdTest
//
//  Created by Dong.lin on 11-12-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#include <libkern/OSAtomic.h>
#import "NetCmd.h"
#import "AsyncSocket.h"
#import "NetCIMProtocol.h"
#import "CIMNetCommand.h"

@implementation NetCmd
@synthesize delegate;

#pragma mark -
#pragma mark init Methods

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        nSendSequence = 0;
        CurSendData = nil;
        
        asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
        NetRecvLock = [[NSLock alloc] init];
        cimNetHelper = [[CIMNetHelper alloc] init];
        recvDataArray  = [[NSMutableArray alloc]init];
        tagArray = [[NSMutableArray alloc] init];
        
        [NSThread detachNewThreadSelector:@selector(ReceiveDataThread) toTarget:self withObject:nil];
        
        if  (![self InitXML]) return nil;
    }
    
    return self;
}

#pragma mark -
#pragma mark Deal Send/Recv Data Methods

- (NSInteger)GetBufSizeByHead:(NSData*)headData
{
    PNETBASEHEADER pHeader   = (PNETBASEHEADER)[headData bytes];
    NSInteger nDataLen = 0;
    NSInteger nCount = 0;
    
    nDataLen = ((pHeader->byFlags & NWPH_USER_DATA) ? (NETHEADERPACKET_SIZE - NETBASEHEADER_SIZE) : 0);
    
    if (pHeader->dwLength != 0)
    {
        nCount++;                                                               
        // CRC
        if((pHeader->byFlags & NWPH_SINGLEPACKET) != NWPH_SINGLEPACKET) nCount++;                                                              
        // Data sequence
        if(pHeader->byFlags & NWPH_PROCESSED) nCount++;                                                                                       
        // Original size
        if((pHeader->byFlags & NWPH_PROCESSED) == NWPH_PROCESSED) nCount++;
        
        
        nDataLen += nCount * sizeof(DWORD);
        nDataLen += pHeader->dwLength;
    }
    return nDataLen;
}

- (BOOL)IsHeartBeatData:(NSData *)data
{
    PNETBASEHEADER pHeader   = (PNETBASEHEADER)[data bytes];
    if (data.length == 16 && pHeader->wCommand == NCMD_HeartBeat
        && (0xC453 == *((WORD*)(([data bytes])+sizeof(WORD))))
        ) 
        return YES;
    return NO;
}

- (void)DistributeCommand
{
    switch (wDataRecvCommand) {
        case NCMD_ReqSysParam:
            switch (byDataRecvComment){
                case RSP_SYSWINPARAMS:
                    //[self AssignFrameWndLayout:pbyData dwLength:dwLength];
                    break;
                    
                case RSP_ACCBOOKPARAMS:
                    //[self AssignBookWndLayout:pbyData dwLength:dwLength];
                    break;
                    
                case RSP_ACCBOOKICONPACKAGES:
                    //[self InitCreateButton:pbyData dwLength:dwLength];
                    break;
                    
                case RSP_SLNSYSWINPARAMS:
                    //[self AssignFrameWndLayout:pbyData dwLength:dwLength];
                    break;
                    
                case RSP_SLNICONPACKAGES:
                    //[self AssignFrameWndLayout:pbyData dwLength:dwLength];
                    break;
                    
                case RSP_SLNTABPARAMS:
                    //[self AssignFrameWndLayout:pbyData dwLength:dwLength];
                    break;
                    
                default:
                    break;
            }
            break;
            
        case NCMD_ReqImage:
            switch (byDataRecvComment) {
                case RIC_GETIMGLIST:
                    //[self InitImageList:pbyData dwLength:dwLength];                    
                    break;
                    
                case RIC_GETIMGDATA:
                    //[self InitImageData:pbyData dwLength:dwLength];                    
                    break;    
                    
                default:
                    break;
            }
            break;
        case NCMD_Login:
            [delegate OnLoginEnd:pDataRecv dwLength:nDataRecvSize commad:wDataRecvCommand comment:byDataRecvComment userdata:dlwDataRecvUserData];
            break;
        case NCMD_Logout:
            [delegate OnLogoutEnd:pDataRecv dwLength:nDataRecvSize commad:wDataRecvCommand comment:byDataRecvComment userdata:dlwDataRecvUserData];
            break;
        case NCMD_RequestLogout:
            [delegate OnRequestLogout:pDataRecv dwLength:nDataRecvSize commad:wDataRecvCommand comment:byDataRecvComment userdata:dlwDataRecvUserData];
            break;
        case NCMD_MobileGet:
        case NCMD_MobilePost:
        {
            NSMutableTable * pTable = [self parseTagBuf:pDataRecv dwLength:nDataRecvSize];
            [delegate OnGetData:pTable comment:byDataRecvComment userdata:dlwDataRecvUserData];
            [pTable release];
        }
            break;
       
            
            break;     
        default:
            break;
    }
}

- (void)OnPacketCRCError
{
    [delegate OnPacketCRCError];
}

- (void)ParseRecvData:(NSData*)pbyData{
    
    if (pbyData.length == 16) {
        
        PNETBASEHEADER   pHeader = (PNETBASEHEADER)[pbyData bytes];
        pDataRecv = nil;
        nDataRecvSize = 0;
        wDataRecvCommand = pHeader->wCommand;
        byDataRecvComment = pHeader->byComment;
        dlwDataRecvUserData = 0;
        [self performSelectorOnMainThread:@selector(DistributeCommand) withObject:self  waitUntilDone:YES];
    }
    else
    {
        PNETBASEHEADER  pHeader = (PNETBASEHEADER)[pbyData bytes];
        BYTE            byFlags = pHeader->byFlags;
        PBYTE           pbyBlkData = (PBYTE)pHeader + (NETBASEHEADER_SIZE + ((byFlags & NWPH_USER_DATA) ? (NETHEADERPACKET_SIZE - NETBASEHEADER_SIZE) : 0));

        pbyBlkData += sizeof(DWORD);
        if((byFlags & NWPH_SINGLEPACKET) != NWPH_SINGLEPACKET)
        {   // Data sequence
            pbyBlkData += sizeof(DWORD);
        }
        if(byFlags & NWPH_PROCESSED)
        {   // Original size
            pbyBlkData += sizeof(DWORD);
        }
        if((byFlags & NWPH_PROCESSED) == NWPH_PROCESSED)
        {   // Packed size
            pbyBlkData += sizeof(DWORD);
        }
        
        if (pHeader->dwLength != 0)
        {
            DWORD dwCRC = [CRCOperation mGetCRC32Reversed:pbyBlkData dwLength:pHeader->dwLength];
            DWORD dwCRCGet = 0;
            
            if(byFlags & NWPH_USER_DATA)
            {
                dwCRCGet = *(DWORD *)((PBYTE)pHeader + sizeof(NETBASEHEADER) + sizeof(DWORD64));
            }
            else
            {
                dwCRCGet = *(DWORD *)((PBYTE)pHeader + sizeof(NETBASEHEADER));
            }
            
            if (dwCRC != dwCRCGet) 
            {
                [self performSelectorOnMainThread:@selector(OnPacketCRCError) withObject:self waitUntilDone:YES];
                return;
            }
        }

        pDataRecv = pbyBlkData;
        nDataRecvSize = pHeader->dwLength;
        wDataRecvCommand = pHeader->wCommand;
        byDataRecvComment = pHeader->byComment;
        if(byFlags & NWPH_USER_DATA)
        {
            DWORD64 * pUserData = (DWORD64 *)((PBYTE)pHeader + sizeof(NETBASEHEADER));
            dlwDataRecvUserData = * pUserData;
        }
        [self performSelectorOnMainThread:@selector(DistributeCommand) withObject:self  waitUntilDone:YES];
       
        return;
    }
}

- (void)ReceiveDataThread {
    while (1) {
        if ([NetRecvLock tryLock])
        {
            if (recvDataArray.count == 0) {
                [NetRecvLock unlock];
                sleep(1);
                continue;
            }
            
            NSData * pData = (NSData *)[recvDataArray objectAtIndex:0];
            [pData retain];
            [recvDataArray removeObjectAtIndex:0];
            [NetRecvLock unlock];
            
            [self ParseRecvData:pData];
            [pData release];
        }
    }
}

- (long)sendCIMData:(AsyncSocket*)socket netCommand:(NETCOMMAND)netCommand pbyData:(BYTE*)pbyData size:(UInt32)dwLength userData:(DWORD64)dlwUserData DataSequence:(DWORD)dwDataSequence OriginalSize:(DWORD)dwOriginalSize PackedSize:(DWORD)dwPackedSize{
    
    UInt32 nDataSendSize = NETBASEHEADER_SIZE;
    if (netCommand.byFlags & NWPH_USER_DATA) nDataSendSize = NETHEADERPACKET_SIZE;
    if (dwLength != 0) {
        nDataSendSize += sizeof(DWORD);                                             // CRC
        
        if((netCommand.byFlags & NWPH_SINGLEPACKET) != NWPH_SINGLEPACKET)			// Data sequence
           nDataSendSize += sizeof(DWORD);

        if(netCommand.byFlags & NWPH_PROCESSED)										// Original size
            nDataSendSize += sizeof(DWORD);

        if((netCommand.byFlags & NWPH_PROCESSED) == NWPH_PROCESSED)					// Packed size
            nDataSendSize += sizeof(DWORD);
        
        nDataSendSize += dwLength;
    }
   
    void* pDataSend = malloc(nDataSendSize);
    if (pDataSend) {
        memset(pDataSend, 0, nDataSendSize);
        
        DWORD dwSequence = OSAtomicIncrement32(&nSendSequence);
        
        void * pCurPoint     = pDataSend;
        
        PNETBASEHEADER pHead = (PNETBASEHEADER)pCurPoint;
        pHead->wIdentifier    = NWPH_IDENTIFIER;
        pHead->dwSequence     = dwSequence;
        pHead->dwLength       = dwLength;
        pHead->wCommand       = netCommand.wCommand;
        pHead->byComment      = netCommand.byComment;
        pHead->byFlags        = netCommand.byFlags & (~NWPH_CALLER_DATA);
        
        pCurPoint += sizeof(NETBASEHEADER);
        
        if (netCommand.byFlags & NWPH_USER_DATA) {
            DWORD64 * pUserData = (DWORD64 *)pCurPoint;
            pCurPoint += sizeof(DWORD64);
            
            *pUserData = dlwUserData;
            pHead->wHeaderCRC     = [CRCOperation mGetCRC16Reversed:pDataSend + sizeof(WORD) dwLength:NETHEADERPACKET_SIZE - sizeof(WORD)];
        }
        else
            pHead->wHeaderCRC     = [CRCOperation mGetCRC16Reversed:pDataSend + sizeof(WORD) dwLength:NETBASEHEADER_SIZE - sizeof(WORD)];
    
        
        if (dwLength != 0) {                                          // CRC
            DWORD * pdwCRCData = (DWORD *)pCurPoint;
            *pdwCRCData = [CRCOperation mGetCRC32Reversed:pbyData dwLength:dwLength];
            pCurPoint += sizeof(DWORD);
            
            if((netCommand.byFlags & NWPH_SINGLEPACKET) != NWPH_SINGLEPACKET)			// Data sequence
            {
                DWORD * pdwCRCData = (DWORD *)pCurPoint;
                *pdwCRCData = dwDataSequence;
                pCurPoint += sizeof(DWORD);
            }
            if(netCommand.byFlags & NWPH_PROCESSED)										// Original size
            {
                DWORD * pdwCRCData = (DWORD *)pCurPoint;
                *pdwCRCData = dwOriginalSize;
                pCurPoint += sizeof(DWORD);
            }
            if((netCommand.byFlags & NWPH_PROCESSED) == NWPH_PROCESSED)					// Packed size
            {
                DWORD * pdwCRCData = (DWORD *)pCurPoint;
                *pdwCRCData = dwPackedSize;
                pCurPoint += sizeof(DWORD);
            }
        }
        
        memcpy(pCurPoint, pbyData, dwLength);
        
        NSData *sendData = [[NSData alloc] initWithBytes:pDataSend length:nDataSendSize];    
        
        [socket writeData:sendData withTimeout:-1 tag:dwSequence];
        
        free(pDataSend);
        [sendData release];
        
        return dwSequence;
    }
    return -1;
}

#pragma mark -
#pragma mark AsyncSocket Methods

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err{
    NSLog(@"Disconnecting. Error: %@", [err localizedDescription]);
}

- (void) onSocketDidDisconnect:(AsyncSocket *)sock{
    NSLog(@"Disconnected.");
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock{
    NSLog(@"onSocketWillConnect");
    return YES;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    NSLog(@"Connected To %@:%i.", host, port);
    
    nBytesToRead = NETBASEHEADER_SIZE;
    [asyncSocket readDataToLength:nBytesToRead withTimeout:-1 tag:0];
    bReadHead = YES;
    recvData = [[NSMutableData alloc] init];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"onSocket:didReadData:%u Bytes.", data.length);
    
    if (bReadHead && [self IsHeartBeatData:data])
    {
        [asyncSocket readDataToLength:NETBASEHEADER_SIZE withTimeout:-1 tag:0];
        return;
    }
    
    [recvData appendData:data];
    nBytesToRead -= data.length;
    if (nBytesToRead == 0)
    {
        if (bReadHead)
        {
            bReadHead = NO;
            nBytesToRead = [self GetBufSizeByHead:recvData];
        }
    }
    
    if (nBytesToRead == 0) {
        [NetRecvLock lock];
        [recvDataArray addObject:recvData];
        [recvData release];
        [NetRecvLock unlock];
        
        recvData = [[NSMutableData alloc] init];
        bReadHead = YES;
        nBytesToRead = NETBASEHEADER_SIZE;
    } 
    
    [asyncSocket readDataToLength:nBytesToRead withTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
	NSLog(@"onSocket:didWriteDataWithTag:%ld.", tag);
    [delegate OnDataSend:tag];
}

#pragma mark -
#pragma mark NSXMLParserDelegate Methods
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName 
    attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"tag"])
	{
        TAGBASE * pBase = malloc(sizeof(TAGBASE));
        memset(pBase, 0, sizeof(TAGBASE));
        pBase->strDesc = [[NSString alloc] initWithString:[attributeDict valueForKey:@"desc"]];
        NSString * strValue = [attributeDict valueForKey:@"value"];
        if ([strValue compare:@"MOGUID"] == NSOrderedSame) {
            pBase->dataType = DataTypeGUID;
        }
        
        if ([strValue compare:@"MOSTRING"] == NSOrderedSame) {
            pBase->dataType = DataTypeString;
        }
        
        if ([strValue compare:@"MONUMBER"] == NSOrderedSame) {
            pBase->dataType = DataTypeNumber;
        }
        
        
        if ([strValue compare:@"MOPICTURE"] == NSOrderedSame) {
            pBase->dataType = DataTypePicture;
        }
        
        if ([strValue compare:@"MOEXCEPTION"] == NSOrderedSame) {
            pBase->dataType = DataTypeException;
        }
        
        NSString * strKey = [attributeDict valueForKey:@"key"];
        [strKey getBytes:pBase->szTagName maxLength:4 usedLength:nil encoding:NSASCIIStringEncoding options:NSStringEncodingConversionAllowLossy range:NSMakeRange(0, strKey.length) remainingRange:nil];
        
        NSData * pTagBase = [[NSData alloc] initWithBytes:(void *)pBase length:sizeof(TAGBASE)];
        [tagArray addObject:pTagBase];
        [pTagBase release];
    }
    
    if ([elementName isEqualToString:@"request"]) {
        curComment = malloc(sizeof(COMMENTBASE));
        curComment->nCommentID = [[attributeDict valueForKey:@"comment"] intValue];
        curComment->strCommentKey = [[NSMutableArray alloc] init];
    }
    
    if ([elementName isEqualToString:@"param"]) {
        NSString * strKey = [[NSString alloc]initWithString:[attributeDict valueForKey:@"key"]];
        [curComment->strCommentKey addObject:strKey];
        [strKey release];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"request"]) {
        NSData * pData = [[NSData alloc] initWithBytes:(void *)curComment length:sizeof(COMMENTBASE)];
        [commentArray addObject:pData];
        [pData release];
    }
}

#pragma mark -
#pragma mark Function Helper Methods
- (NSMutableTable *) parseTagBuf:(PBYTE)dataRecv dwLength:(DWORD)dataSize
{
    if (dataRecv) {
        uint nRowCount = *(uint *)dataRecv;
        if (nRowCount > 0) {
            uint * nRowOffset = (uint *)(dataRecv + sizeof(uint));
            
            NSMutableTable * pTableArray = [[NSMutableTable alloc] init];

            for (int n = 0; n < nRowCount; n ++) {
                TableObj * pTable = nil;
                
                int nSizeRemain = 0;
                if (n == (nRowCount - 1)) {
                    nSizeRemain = dataSize - nRowOffset[n];
                }
                else
                    nSizeRemain = nRowOffset[n + 1] - nRowOffset[n];
                
                RowObj * pRow = [[RowObj alloc] initWithData:dataRecv + nRowOffset[n] MaxSize:nSizeRemain BaseTag:tagArray];
                if (pRow) {
                    TagObj * pTag = [pRow GetTagValue:@"dl"];
                
                    if (pTag != nil) {
                       
                        for (int nTable = 0; nTable < pTableArray.TableArray.count; nTable ++) {
                            pTable = (TableObj *)[pTableArray.TableArray objectAtIndex:nTable];
                            if ([pTable.strTable compare:pTag.strValue] == NSOrderedSame) {
                                break;
                            }
                            pTable = nil;
                        }
                        if (pTable == nil) {
                            pTable = [[TableObj alloc] initWithString:pTag.strValue];
                            [pTableArray.TableArray addObject:pTable];
                            [pTable release];
                        }
                    }
                    
                    if (pTable != nil)
                        [pTable addRow:pRow];
                }
            }

            return pTableArray;
        }
    }
    return nil;
}

- (void) GenTagBuf:(NSMutableData *)pData GUID:(GUID)guid tagName:(NSString *)strTagName
{
    TAGDATA data;
    memset(&data, 0, sizeof(TAGDATA));
    
    [strTagName getBytes:data.szTagName maxLength:4 usedLength:nil encoding:NSASCIIStringEncoding options:NSStringEncodingConversionAllowLossy range:NSMakeRange(0, strTagName.length) remainingRange:nil];
    data.nTagDataSize = sizeof(GUID);
    [pData appendBytes:&data length:sizeof(TAGDATA)];
    [pData appendBytes:&guid length:sizeof(GUID)];
}

- (void) GenTagBuf:(NSMutableData *)pData String:(NSString *)strBuf tagName:(NSString *)strTagName
{
    TAGDATA data;
    memset(&data, 0, sizeof(TAGDATA));
    
    NSInteger nDataSize = strBuf.length * sizeof(unichar);
    [strTagName getBytes:data.szTagName maxLength:4 usedLength:nil encoding:NSASCIIStringEncoding options:NSStringEncodingConversionAllowLossy range:NSMakeRange(0, strTagName.length) remainingRange:nil];
    data.nTagDataSize = nDataSize;
    [pData appendBytes:&data length:sizeof(TAGDATA)];
    
    unichar * pChar = malloc(nDataSize);
    [strBuf getBytes:pChar maxLength:nDataSize usedLength:nil encoding:NSUnicodeStringEncoding options:NSStringEncodingConversionAllowLossy range:NSMakeRange(0, nDataSize) remainingRange:nil];
    [pData appendBytes:pChar length:nDataSize];
    
    free(pChar);
}

- (void)GenTagBuf:(NSMutableData *)pData NumberValue:(id)value tagName:(NSString *)strTagName
{
    TAGDATA data;
    memset(&data, 0, sizeof(TAGDATA));
    [strTagName getBytes:data.szTagName maxLength:4 usedLength:nil encoding:NSASCIIStringEncoding options:NSStringEncodingConversionAllowLossy range:NSMakeRange(0, strTagName.length) remainingRange:nil];
    data.nTagDataSize = 8;
    [pData appendBytes:&data length:sizeof(TAGDATA)];
    
    [pData appendBytes:(void *)value length:8];
}

#pragma mark -
#pragma mark Function Methods
- (BOOL) InitXML
{
    NSXMLParser * xmlPaser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tag.xml" ofType:nil]]];
    if (xmlPaser) {
        [xmlPaser setDelegate:self];
        [xmlPaser parse];
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark Server connecting Function Methods

- (BOOL) ConnectServer:(NSString *)strServerAddress Port:(NSInteger)nPort error:(NSError **)errPtr 
{
    return [asyncSocket connectToHost:strServerAddress onPort:nPort error:errPtr];
}

- (long) LoginUserName:(NSString *)strNSUserName PassWord:(NSString *)strNSPassWord ComputerNameDnsHostname:(NSString *)strNSComputerNameDnsHostname strNSComputerDescription:(NSString *)strNSComputerDescription strNSLocalNetAddress:(NSString *)strNSLocalNetAddress Lcid:(LCID)lcidLanguage UserData:(DWORD64)dwUserData
{
    DWORD   dwSize                          = 0;
    PBYTE   pbyBuffer                       = nil;
    
    LPCTSTR strUserName                   = (LPCTSTR)[strNSUserName cStringUsingEncoding:NSUnicodeStringEncoding];
    LPCTSTR strPassWord                   = (LPCTSTR)[strNSPassWord cStringUsingEncoding:NSUnicodeStringEncoding];
    LPCTSTR strComputerNameDnsHostname    = (LPCTSTR)[strNSComputerNameDnsHostname cStringUsingEncoding:NSUnicodeStringEncoding];
    LPCTSTR strComputerDescription        = (LPCTSTR)[strNSComputerDescription cStringUsingEncoding:NSUnicodeStringEncoding];
    LPCSTR strLocalNetAddress             = (LPCSTR)[strNSLocalNetAddress cStringUsingEncoding:NSASCIIStringEncoding];
    
    NETCOMMAND netCommand;
    netCommand.wCommand     = NCMD_Login;
    netCommand.byComment    = LGICT_LOGIN;
    netCommand.byFlags      = NWPH_BEGINNING | NWPH_ENDING | NWPH_USER_DATA;
    
    
    [cimNetHelper ResetOffset:sizeof(NDATLogin)];
    
    dwSize = sizeof(NDATLogin)+ 
    [cimNetHelper CountSizeWTNAME:strComputerNameDnsHostname dwLength:[strNSComputerNameDnsHostname length]] + 
    [cimNetHelper CountSizeWTNAME:strComputerDescription dwLength:[strNSComputerDescription length]] + 
    [cimNetHelper CountSizeWTNAME:strUserName dwLength:[strNSUserName length]] + 
    [cimNetHelper CountSizeWTNAME:strPassWord dwLength:[strNSPassWord length]] + 
    [cimNetHelper CountSizeWANAME:strLocalNetAddress dwLength:[strNSLocalNetAddress length]];
    
    pbyBuffer = (PBYTE)malloc(dwSize);
    [cimNetHelper SetBuffer:pbyBuffer dwStartOffset:sizeof(NDATLogin) dwBufferSize:dwSize];
    
    ((PNDATLogin)pbyBuffer)->wMachineName           = [cimNetHelper SetOffsetWTNAME:strComputerNameDnsHostname dwBufferLen:[strNSComputerNameDnsHostname length]];
	((PNDATLogin)pbyBuffer)->wComputerDescription   = [cimNetHelper SetOffsetWTNAME:strComputerDescription dwBufferLen:[strNSComputerDescription length]];
	((PNDATLogin)pbyBuffer)->wUsername              = [cimNetHelper SetOffsetWTNAME:strUserName dwBufferLen:[strNSUserName length]];
	((PNDATLogin)pbyBuffer)->wPassword              = [cimNetHelper SetOffsetWTNAME:strPassWord dwBufferLen:[strNSPassWord length]];
	((PNDATLogin)pbyBuffer)->wInternalIP            = [cimNetHelper SetOffsetWANAME:strLocalNetAddress dwBufferLen:[strNSLocalNetAddress length]];
	((PNDATLogin)pbyBuffer)->lcidUILanguage         = lcidLanguage;
    
    long nRet = [self sendCIMData:asyncSocket netCommand:netCommand pbyData:pbyBuffer size:dwSize userData:dwUserData DataSequence:0 OriginalSize:0 PackedSize:0];   
    
    free(pbyBuffer);
    return nRet;
}

- (long) Logout :(GUID)guidWorkspace UserData:(DWORD64)dwUserData
{
    NDATLogout *logout = nil; 
    NETCOMMAND netCommand;
    netCommand.wCommand     = NCMD_Logout;
    netCommand.byComment    = LGOCT_NORMAL;
    netCommand.byFlags      = NWPH_BEGINNING | NWPH_ENDING | NWPH_USER_DATA;
    
    logout = (NDATLogout*)malloc(sizeof(NDATLogout));
    memset(logout, 0, sizeof(NDATLogout));
    
    logout->guidWorkspace = guidWorkspace;
    long nRet =  [self sendCIMData:asyncSocket netCommand:netCommand pbyData:(void*)logout size:sizeof(NDATLogout) userData:dwUserData DataSequence:0 OriginalSize:0 PackedSize:0];  
    
    free(logout);
    return nRet;
}

- (long) SendCommandData:(NSMutableArray *)tagBuf SolutionGuid:(GUID)guidSolution userData:(DWORD64)dwUserData command:(WORD)wCommand comment:(BYTE)byComment
{
    NETCOMMAND netCommand;
    netCommand.wCommand     = wCommand;
    netCommand.byComment    = byComment;
    netCommand.byFlags      = NWPH_BEGINNING | NWPH_ENDING | NWPH_USER_DATA;
    
    if (tagBuf == nil || tagBuf.count == 0) {
        return [self sendCIMData:asyncSocket netCommand:netCommand pbyData:(void*)&guidSolution size:sizeof(GUID) userData:dwUserData DataSequence:0 OriginalSize:0 PackedSize:0];
    }
    
    NSInteger nSendDataSize = sizeof(SETDATA);

    nSendDataSize+= sizeof(uint) * tagBuf.count;
    for (int n = 0; n < tagBuf.count; n ++) {
        NSMutableData * pDataRow = [tagBuf objectAtIndex:n];
        nSendDataSize += pDataRow.length;
    }
    
    SETDATA * pSetData = (SETDATA *)malloc(nSendDataSize);
    pSetData->guidSolution = guidSolution;
    pSetData->nRowCount = tagBuf.count;
    uint * pOffset = (uint *)((PBYTE)pSetData + sizeof(SETDATA));
    BYTE * pTagData = (PBYTE)pSetData + sizeof(SETDATA) + sizeof(uint) * tagBuf.count;
    NSInteger nRowOffset = sizeof(SETDATA) + sizeof(uint) * tagBuf.count;
    
    for (int n = 0; n < tagBuf.count; n ++) {
        pOffset[n] = nRowOffset;
        
        NSMutableData * pDataRow = [tagBuf objectAtIndex:n];
        memcpy(pTagData, pDataRow.bytes, pDataRow.length);
        pTagData += pDataRow.length;
        nRowOffset += pDataRow.length;
    }
    
    long nRet =  [self sendCIMData:asyncSocket netCommand:netCommand pbyData:(void*)pSetData size:nSendDataSize userData:dwUserData DataSequence:0 OriginalSize:0 PackedSize:0];  

    free(pSetData);
    return nRet;
}

- (void) AddSendData:(NSMutableArray *)pRowArray TableID:(NSString *)strTable
{
    if (CurSendData == nil) CurSendData = [[NSMutableArray alloc] init];

    if  (CurSendData)
    {
        NSMutableData * pDataRow = [[NSMutableData alloc] init];

        for (int n = 0; n < pRowArray.count; n ++) {
            TagObj * pTag = (TagObj *)[pRowArray objectAtIndex:n];
            if (pTag) {
                switch (pTag.dataType) {
                    case DataTypeGUID:
                        [self GenTagBuf:pDataRow GUID:pTag.guidValue tagName:pTag.strTagKey];
                        break;
                    case DataTypeString:
                        [self GenTagBuf:pDataRow String:pTag.strValue tagName:pTag.strTagKey];
                        break;
                    case DataTypeNumber:
                        switch (pTag.numbertype) {
                            case MNE_Int:
                            {
                                int nValue = pTag.intValue;
                                [self GenTagBuf:pDataRow NumberValue:(id)&nValue tagName:pTag.strTagKey];
                            }
                            break;
                                
                            case MNE_Double:
                            {
                                double dValue = pTag.dValue;
                                [self GenTagBuf:pDataRow NumberValue:(id)&dValue tagName:pTag.strTagKey];
                            }
                            break;
                                
                            case MNE_Float:
                            {
                                float fValue = pTag.fValue;
                                [self GenTagBuf:pDataRow NumberValue:(id)&fValue tagName:pTag.strTagKey];
                            }
                            break;
                                
                            case MNE_UInt:
                            {
                                uint nValue = pTag.uintValue;
                                [self GenTagBuf:pDataRow NumberValue:(id)&nValue tagName:pTag.strTagKey];
                            }
                            break;
                        }
                        break;
                    default:
                        break;
                }
            }
        }
        
        [self GenTagBuf:pDataRow String:strTable tagName:@"dl"];
        
        [CurSendData addObject:pDataRow];
        [pDataRow release];
    }
}

- (void) CleanSendData
{
    [CurSendData release];
    CurSendData = nil;
}

- (long) CommitSend:(GUID)guidSolution CommentID:(BYTE)nCommentID IsGetComment:(BOOL)bGet UserData:(DWORD64)dwUserData
{
    WORD nCommand = NCMD_MobileGet;
    if (!bGet) nCommand = NCMD_MobilePost;
    
    long nRet = [self SendCommandData:CurSendData SolutionGuid:guidSolution userData:dwUserData command:nCommand comment:nCommentID];
    [CurSendData release];
    CurSendData = nil;
    return nRet;
}

@end
