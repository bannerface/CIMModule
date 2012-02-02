//
//  CIMDBEngine.h
//  CIMModule
//
//  Created by 林 董 on 12-2-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PlausibleDatabase/PlausibleDatabase.h>

@protocol CIMDBTaskDelgate 

-(BOOL)InitTableByXML:(NSData *)xmlData;

@end

@interface CIMDBEngine : NSObject<CIMDBTaskDelgate,NSXMLParserDelegate>
{
    PLSqliteDatabase        * dbPointer; 
}

-(id)initWithFileName:(NSString *)strFileName;

@end
