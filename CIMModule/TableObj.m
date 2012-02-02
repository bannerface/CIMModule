//
//  TableObj.m
//  iShowProduct
//
//  Created by 董 林 on 11-12-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TableObj.h"

#pragma mark -
#pragma mark TableObj Methods
@implementation TableObj

@synthesize strTable,rowArray;

-(id)initWithString:(NSString *)str
{
    self = [super init];
    if (self) {
        strTable = [[NSString alloc] initWithString:str]; 
        rowArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)addRow:(RowObj *)pRow;
{
    if (pRow) {
        [rowArray addObject:pRow];
        [pRow release];
    }
}

-(void)dealloc
{
    [strTable release];
    [rowArray release];
    [super dealloc];
}
@end