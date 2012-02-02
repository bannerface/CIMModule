//
//  NSMutableTable.m
//  iShowProduct
//
//  Created by 董 林 on 11-12-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSMutableTable.h"

#pragma mark -
#pragma mark NSMutableTable Methods

@implementation NSMutableTable

@synthesize TableArray;

-(id)init
{
    self = [super init];
    if (self) {
        TableArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(TableObj *)GetTable:(NSString *)strTable
{
    for (int n = 0; n < TableArray.count; n ++) {
        TableObj * pTable = (TableObj *)[TableArray objectAtIndex:n];
        if ([pTable.strTable compare:strTable] == NSOrderedSame) {
            return pTable;
        }
    }
    return nil; 
}

-(RowObj *)GetTableRow:(NSString *)strTable RowIndex:(NSInteger)nRowIndex
{
    for (int n = 0; n < TableArray.count; n ++) {
        TableObj * pTable = (TableObj *)[TableArray objectAtIndex:n];
        if ([pTable.strTable compare:strTable] == NSOrderedSame) {
            return (RowObj *)[pTable.rowArray objectAtIndex:nRowIndex];
        }
    }
    return nil; 
}

-(TagObj *)GetTableRowTagValue:(NSString *)strTable RowIndex:(NSInteger)nRowIndex TagKey:(NSString *)strKey
{
    for (int n = 0; n < TableArray.count; n ++) {
        TableObj * pTable = (TableObj *)[TableArray objectAtIndex:n];
        if ([pTable.strTable compare:strTable] == NSOrderedSame) {
            RowObj * pRow = (RowObj *)[pTable.rowArray objectAtIndex:nRowIndex];
            if (pRow) {
                return [pRow GetTagValue:strKey];
            }
            break;
        }
    }
    return nil;
}
@end
