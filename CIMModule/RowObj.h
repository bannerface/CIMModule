//
//  RowObj.h
//  iShowProduct
//
//  Created by 董 林 on 11-12-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIMBaseType.h"
#import "TagProtocol.h"
#import "TagOjb.h"

@interface RowObj : NSObject {
    NSMutableArray  * tagArray;
}

@property (nonatomic,retain,readonly) NSMutableArray * tagArray;

-(id)initWithData:(PBYTE)pData MaxSize:(NSInteger)nSize BaseTag:(NSMutableArray *)baseTagArray;
-(TagObj *)GetTagValue:(NSString *)strTagName;

@end