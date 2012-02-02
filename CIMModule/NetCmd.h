//
//  NetCmd.h
//  NetCmdTest
//
//  Created by Dong.lin on 11-12-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIMNetHelper.h"
#import "CRC.h"
#import "TagProtocol.h"
#import "ipadProtocol.h"
#import "NSMutableTable.h"

@class AsyncSocket;

//NetCmd delegate
@protocol NetCmdDelegate

-(void)OnPacketCRCError;
-(void)OnDataSend:(long)tag;

-(void)OnLoginEnd:(void *)pbyData dwLength:(UInt32)dwLength commad:(WORD)wDataRecvCommand comment:(BYTE)byDataRecvComment userdata:(DWORD64)dlwDataRecvUserData;
-(void)OnLogoutEnd:(void *)pbyData dwLength:(UInt32)dwLength commad:(WORD)wDataRecvCommand comment:(BYTE)byDataRecvComment userdata:(DWORD64)dlwDataRecvUserData;
-(void)OnRequestLogout:(void *)pbyData dwLength:(UInt32)dwLength commad:(WORD)wDataRecvCommand comment:(BYTE)byDataRecvComment userdata:(DWORD64)dlwDataRecvUserData;

-(void)OnGetData:(NSMutableTable *)tableArray comment:(BYTE)byDataRecvComment userdata:(DWORD64)dlwDataRecvUserData;

@end

//class
@interface NetCmd : NSObject<NSXMLParserDelegate>
{
    id<NetCmdDelegate>      delegate;
    AsyncSocket             *asyncSocket;
    CIMNetHelper            *cimNetHelper;
    
    NSInteger               nSendSequence;
    
    NSMutableArray          *tagArray;
    NSMutableArray          *commentArray;
    COMMENTBASE             *curComment;
    
    NSLock                  *NetRecvLock;
    NSMutableArray          *recvDataArray;
    NSMutableData           *recvData;
    NSInteger               nBytesToRead;
    BOOL                    bReadHead;
    
    PBYTE                   pDataRecv;
    DWORD                   nDataRecvSize;
    WORD                    wDataRecvCommand;
    BYTE                    byDataRecvComment;
    DWORD64                 dlwDataRecvUserData;
    
    NSMutableArray          * CurSendData;
    NSString                * strCurSendTable;
}

- (NSMutableTable *) parseTagBuf:(PBYTE)dataRecv dwLength:(DWORD)dataSize;

@property(assign,nonatomic) id<NetCmdDelegate>delegate;
- (BOOL) InitXML;

- (BOOL) ConnectServer:(NSString *)strServerAddress Port:(NSInteger)nPort error:(NSError **)errPtr;
- (long) LoginUserName:(NSString *)strNSUserName PassWord:(NSString *)strNSPassWord ComputerNameDnsHostname:(NSString *)strNSComputerNameDnsHostname strNSComputerDescription:(NSString *)strNSComputerDescription strNSLocalNetAddress:(NSString *)strNSLocalNetAddress Lcid:(LCID)lcidLanguage UserData:(DWORD64)dwUserData;
- (long) Logout:(GUID)guidWorkspace UserData:(DWORD64)dwUserData;

- (void) CleanSendData;
- (void) AddSendData:(NSMutableArray *)pRowArray TableID:(NSString *)strTable;
- (long) CommitSend:(GUID)guidSolution CommentID:(BYTE)nCommentID IsGetComment:(BOOL)bGet UserData:(DWORD64)dwUserData;

@end
