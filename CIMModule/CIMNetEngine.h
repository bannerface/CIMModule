//
//  CIMNetEngine.h
//  CIMModule
//
//  Created by 林 董 on 12-2-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIMBaseType.h"
#import "CIMDBEngine.h"

enum CIMNetEngineSyncRetError
{
    SyncErrorNoError = 0,               //没有错误 
    SyncErrorTaskError,                 //此次操作失败
    SyncErrorHasConnectServer,          //已经连接服务器
    SyncErrorHasLogin,                  //已经登陆
    SyncErrorHasNotLogin,               //尚未登陆
};

@interface CIMNetEngine : NSObject<NSXMLParserDelegate>
{
    id<CIMDBTaskDelgate> dbDelegate;     
    
    NSMutableData *webData;
	NSMutableString *soapResults;
	NSXMLParser *xmlParser;
	BOOL recordResults;
}

@property (assign,nonatomic) id<CIMDBTaskDelgate> dbDelegate;

- (long) ConnectServer:(NSString *)strServerAddress Port:(NSInteger)nPort;

- (long) LoginUserName:(NSString *)strNSUserName PassWord:(NSString *)strNSPassWord;

- (long) Logout;

- (long)GetOfflineData:(GUID *)guidCompany Selector:(SEL)method withObject:(id)selRecv;

@end
