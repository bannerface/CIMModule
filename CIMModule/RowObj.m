//
//  RowObj.m
//  iShowProduct
//
//  Created by 董 林 on 11-12-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "RowObj.h"

#pragma mark -
#pragma mark RowObj Methods

@implementation RowObj

@synthesize tagArray;

-(id)initWithData:(PBYTE)pData MaxSize:(NSInteger)nSize BaseTag:(NSMutableArray *)baseTagArray
{
    self = [super init];
    if (self) {
        tagArray = [[NSMutableArray alloc] init];  
        
        PBYTE pTempBuf = pData;
        NSInteger nDataRemain = nSize;
        
        while (nDataRemain > 0) {
            if (nDataRemain >= sizeof(TAGDATA)) {
                TAGDATA * pTagData = (TAGDATA * )pTempBuf;
                if (nDataRemain >= (sizeof(TAGDATA) + pTagData->nTagDataSize)) {
                    TagObj * pTagObj = [[TagObj alloc] initwithTagData:pTagData BaseTag:baseTagArray];
                    if (pTagObj) {
                        [tagArray addObject:pTagObj];
                        [pTagObj release];
                    }
                }
                nDataRemain -= (sizeof(TAGDATA) + pTagData->nTagDataSize);
                pTempBuf += (sizeof(TAGDATA) + pTagData->nTagDataSize);
            }  
            else
                break;
        }
        
    }
    return self;
}

-(TagObj *)GetTagValue:(NSString *)strTagName;
{
    for (int n = 0; n < tagArray.count; n ++) {
        TagObj * pTagObj = (TagObj *)[tagArray objectAtIndex:n];
        if ([pTagObj.strTagKey isEqualToString:strTagName]) {
            return pTagObj;
        }
    }
    return nil;
}

-(void) dealloc
{
    [tagArray release];
    [super dealloc];
}
@end