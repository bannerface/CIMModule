//
//  COperation.m
//  iShowProduct
//
//  Created by 董 林 on 11-12-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "COperation.h"

@implementation COperation

+(NSInteger)GetUnicodeStringLength:(PBYTE)pBuf MAXLength:(uint)nLength
{
    int nCount = 0;
    for (uint n = 0; n < nLength - 1; n ++) {
        if (pBuf[n] == 0 && pBuf[n + 1] == 0) {
            return nCount;
        }
        nCount ++;
    }
    nCount ++;
    return nCount;
}

@end
