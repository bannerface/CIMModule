//
//  TableObj.h
//  iShowProduct
//
//  Created by 董 林 on 11-12-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RowObj.h"

@interface TableObj : NSObject {
    NSString        * strTable;
    NSMutableArray  * rowArray;
}

@property (nonatomic,retain,readonly) NSString * strTable;
@property (nonatomic,retain,readonly) NSMutableArray  * rowArray;

-(id)initWithString:(NSString *)str;
-(void)addRow:(RowObj *)pRow;

@end