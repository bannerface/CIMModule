//
//  CIMNetEngine.m
//  CIMModule
//
//  Created by 林 董 on 12-2-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CIMNetEngine.h"

@implementation CIMNetEngine
@synthesize dbDelegate;

- (long) ConnectServer:(NSString *)strServerAddress Port:(NSInteger)nPort
{
    return 0;
}

- (long) LoginUserName:(NSString *)strNSUserName PassWord:(NSString *)strNSPassWord
{
    return 0;
}

- (long) Logout
{
    return 0;
}

- (long)GetOfflineData:(GUID *)guidCompany Selector:(SEL)method withObject:(id)selRecv
{
    NSString * strXMLSchema = [[NSBundle mainBundle] pathForResource:@"db.xml" ofType:nil];
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:strXMLSchema];
    NSData *data1 = [file readDataToEndOfFile];
    [file closeFile];
    
    [dbDelegate CreateTableByXML:data1];
    return 0;
}

@end
