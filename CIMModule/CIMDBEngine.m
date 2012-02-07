//
//  CIMDBEngine.m
//  CIMModule
//
//  Created by 林 董 on 12-2-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CIMDBEngine.h"

@implementation CIMFieldElement

@synthesize name,type,string;

-(void)clearValue
{
    [string release];
    string = nil;    
}

@end

@implementation CIMDBEngine


-(id)initWithFileName:(NSString *)strFileName
{
    self = [super init];
    if (self) {
        dbPointer = [[PLSqliteDatabase alloc] initWithPath:strFileName];
        if (dbPointer) {
            [dbPointer open];
            bCreatingTable = NO;
            
            return self;
        }
    }
    return nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName 
    attributes:(NSDictionary *)attributeDict
{
    strXMLElement = nil;
    
    if ([elementName isEqualToString:@"xs:schema"]) {
        if (procCreateTable == CreateTable_Begin) {
            procCreateTable = CreateTable_ParseSchemaBegin; 
        }
    }
    
    if ([elementName isEqualToString:@"xs:element"]) {
        NSString * strName = [attributeDict valueForKey:@"name"];
        
        switch (procCreateTable) {
            case CreateTable_ParseSchemaBegin:
                strTableName = [attributeDict valueForKey:@"msdata:MainDataTable"];
                procCreateTable = CreateTable_ParseDataSetBegin;
                break;
            case CreateTable_ParseDataSetBegin:
                if ([strName isEqualToString:strTableName]) {
                    procCreateTable = CreateTable_ParseTableBegin;
                }
                break;
            case CreateTable_ParseTableBegin:
            case CreateTable_ParseFieldEnd:
            {
                CIMFieldElement * element = [[CIMFieldElement alloc] init];
                element.name = strName;
                
                NSString * strType = [attributeDict valueForKey:@"type"];
                if ([strType isEqualToString:@"xs:string"]) {
                    element.type = FieldType_string;
                }
                if ([strType isEqualToString:@"xs:int"]) {
                    element.type = FieldType_int;
                }
                if ([strType isEqualToString:@"xs:double"]) {
                    element.type = FieldType_double;
                }
                if ([strType isEqualToString:@"xs:dateTime"]) {
                    element.type = FieldType_DateTime;
                }
                
                [arFields addObject:element];
                
                procCreateTable = CreateTable_ParseFieldBegin;
                
                [element release];
            }
                break;
            default:
                break;
        }
    }
    
    if (procCreateTable >= CreateTable_ParseSchemaEnd)
    {
        if ([elementName isEqualToString:strTableName]) {
            procCreateTable = CreateTable_ParseDataBegin;
            for (int n = 0; n < arFields.count; n ++) {
                CIMFieldElement * element = [arFields objectAtIndex:n];
                [element clearValue];
            }
        }
        
        for (int n = 0; n < arFields.count; n ++) {
            CIMFieldElement * element = [arFields objectAtIndex:n];
            if ([elementName isEqualToString:element.name]) {
                strXMLElement = elementName;
                
                procCreateTable = CreateTable_ParseFieldDataBegin;
                break;
            }
        }
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (procCreateTable == CreateTable_ParseFieldDataBegin)
    {
        for (int n = 0; n < arFields.count; n ++) {
            CIMFieldElement * element = [arFields objectAtIndex:n];
            if ([strXMLElement isEqualToString:element.name]) {
                element.string = string;
                break;
            }
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"xs:element"]){
        switch (procCreateTable) {
            case CreateTable_ParseFieldBegin:
                procCreateTable = CreateTable_ParseFieldEnd;
                break;
            case CreateTable_ParseFieldEnd:
                procCreateTable = CreateTable_ParseTableEnd;
                break;
            case CreateTable_ParseTableEnd:
                procCreateTable = CreateTable_ParseDataSetEnd;
                break;
            default:
                break;
        }
    }
    
    if ([elementName isEqualToString:@"xs:schema"]) {
        procCreateTable = CreateTable_ParseSchemaEnd;
        
        NSString * strCmd = [NSString stringWithFormat:@"drop table %@",strTableName];
        [dbPointer executeUpdate:strCmd];
        
        strCmd = [NSString stringWithFormat:@"CREATE TABLE [%@]",strTableName];
        strCmd = [strCmd stringByAppendingString: @"("];
        
        for (int n = 0; n < arFields.count; n ++) {
            CIMFieldElement *  pElement = (CIMFieldElement *)[arFields objectAtIndex:n];
            strCmd = [strCmd stringByAppendingFormat:@"[%@]",pElement.name];
            
            switch (pElement.type) {
                case FieldType_string:
                    strCmd = [strCmd stringByAppendingString:@" NVARCHAR(512)"];
                    break;
                case FieldType_double:
                    strCmd = [strCmd stringByAppendingString:@" DECIMAL(10,10)"];
                    break;
                case FieldType_int:
                    strCmd = [strCmd stringByAppendingString:@" INT"];
                    break;
                case FieldType_DateTime:
                    strCmd = [strCmd stringByAppendingString:@" DATETIME"];
                    break;
            }
            
            if (n != (arFields.count - 1)) {
                strCmd = [strCmd stringByAppendingString:@","];
            }
        }
        
        strCmd = [strCmd stringByAppendingString: @");"];
        [dbPointer executeUpdate:strCmd];
    }
    
    if (procCreateTable == CreateTable_ParseFieldDataBegin) {
        for (int n = 0; n < arFields.count; n ++) {
            CIMFieldElement * element = [arFields objectAtIndex:n];
            if ([elementName isEqualToString:element.name]) {
                procCreateTable = CreateTable_ParseFieldDataEnd;
                break;
            }
        }
    }
    
    if ([elementName isEqualToString:strTableName]) {
        procCreateTable = CreateTable_ParseDataEnd;
        
        NSString * strCmd = [NSString stringWithFormat:@"INSERT INTO %@",strTableName];
        NSString * strFieleds = @"";
        NSString * strValues = @"";
        
        for (int n = 0; n < arFields.count; n ++) {
            CIMFieldElement * element = [arFields objectAtIndex:n];
            if (element.string) {
                NSString * strElement = nil;
                
                switch (element.type) {
                    case FieldType_DateTime:
                        strElement = [element.string substringWithRange:NSMakeRange(0,19)];
                        strElement = [strElement stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                        break;
                    default:
                        strElement = element.string;
                        break;
                }
                
                if (strFieleds.length == 0) {
                    strFieleds = [strFieleds stringByAppendingFormat:@"[%@]",element.name];
                    strValues = [NSString stringWithFormat:@"\"%@\"",strElement];
                }
                else
                {
                    strFieleds = [strFieleds stringByAppendingFormat:@",[%@]",element.name];
                    strValues = [strValues stringByAppendingFormat:@",\"%@\"",strElement];
                }
            }
        }
        
        strCmd = [NSString stringWithFormat:@"%@ (%@) VALUES (%@)",strCmd,strFieleds,strValues];
        [dbPointer executeUpdate:strCmd];
    }
}

-(BOOL)CreateTableByXML:(NSData *)xmlData
{
    BOOL bRet = NO;
    
    if (!bCreatingTable)
    {
        bCreatingTable = YES;
        strTableName = nil;
        arFields = [[NSMutableArray alloc] init];
        
        procCreateTable = CreateTable_Begin;
        
        NSXMLParser * xmlPaser = [[NSXMLParser alloc] initWithData:xmlData];
        if (xmlPaser) {
            
            [xmlPaser setDelegate:self];
            [xmlPaser parse];
            bRet = YES;
        }
        bCreatingTable = NO;
    }
    return bRet;
}

@end
