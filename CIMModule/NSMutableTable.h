//
//  NSMutableTable.h
//  iShowProduct
//
//  Created by 董 林 on 11-12-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIMBaseType.h"
#import "TagOjb.h"
#import "RowObj.h"
#import "TableObj.h"

@interface NSMutableTable : NSMutableArray {
    NSMutableArray * TableArray;
}

@property (nonatomic,retain,readonly) NSMutableArray * TableArray;

-(TableObj *)GetTable:(NSString *)strTable;
-(RowObj *)GetTableRow:(NSString *)strTable RowIndex:(NSInteger)nRowIndex;
-(TagObj *)GetTableRowTagValue:(NSString *)strTable RowIndex:(NSInteger)nRowIndex TagKey:(NSString *)strKey;

@end

