//
//  CIMDBEngine.m
//  CIMModule
//
//  Created by 林 董 on 12-2-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CIMDBEngine.h"

@implementation CIMDBEngine

-(id)initWithFileName:(NSString *)strFileName
{
    self = [super init];
    if (self) {
        dbPointer = [[PLSqliteDatabase alloc] initWithPath:strFileName];
        if (dbPointer) {
            [dbPointer open];
            return self;
        }
    }
    return nil;
}


#pragma mark -
#pragma mark NSXMLParserDelegate Methods
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName 
    attributes:(NSDictionary *)attributeDict
{
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
}

-(BOOL)InitTableByXML:(NSData *)xmlData
{
    NSXMLParser * xmlPaser = [[NSXMLParser alloc] initWithData:xmlData];
    if (xmlPaser) {
        [xmlPaser setDelegate:self];
        [xmlPaser parse];
        return YES;
    }
    return NO;
}

@end
