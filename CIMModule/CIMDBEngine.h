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

-(BOOL)CreateTableByXML:(NSData *)xmlData;

@end

typedef enum
{
    CreateTable_Begin,
    CreateTable_ParseSchemaBegin,
    CreateTable_ParseDataSetBegin,
    CreateTable_ParseTableBegin,
    CreateTable_ParseFieldBegin,
    CreateTable_ParseFieldEnd,
    CreateTable_ParseTableEnd,
    CreateTable_ParseDataSetEnd,
    CreateTable_ParseSchemaEnd,
    
    CreateTable_ParseDataBegin,
    CreateTable_ParseFieldDataBegin,
    CreateTable_ParseFieldDataEnd,
    CreateTable_ParseDataEnd,
}CreateTableProc;

typedef enum 
{
   FieldType_string,
   FieldType_int,
   FieldType_double,
}FieldType;

@interface CIMFieldElement : NSObject {
    NSString * name;
    NSString * string;
    FieldType  type;
}

-(void)clearValue;

@property (assign,nonatomic) NSString * name;
@property (assign,nonatomic) FieldType  type;
@property (retain,nonatomic) NSString * string;

@end


@interface CIMDBEngine : NSObject<CIMDBTaskDelgate,NSXMLParserDelegate>
{
    PLSqliteDatabase        * dbPointer; 
    
    BOOL                    bCreatingTable;
    NSString                * strTableName;
    NSString                * strXMLElement;
    NSMutableArray          * arFields;
    CreateTableProc           procCreateTable;
}

-(id)initWithFileName:(NSString *)strFileName;

@end
