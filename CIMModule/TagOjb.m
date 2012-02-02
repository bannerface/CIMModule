//
//  TagOjb.m
//  iShowProduct
//
//  Created by 董 林 on 11-12-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TagOjb.h"

#pragma mark -
#pragma mark TagObj Methods

@implementation TagObj

@synthesize strTagKey,dataType,numbertype,pictureType,strNumberUnit,strValue,dValue,fValue,intValue,uintValue,guidValue,picdataArray;

-(id)initwithTagData:(TAGDATA *) pTagData BaseTag:(NSMutableArray *)baseTagArray
{
    self = [super init];
    if (self && pTagData != nil) {
        strNumberUnit = nil;
        strValue = nil;
        strTagKey = [[NSString alloc]initWithBytes:pTagData->szTagName length:strnlen(pTagData->szTagName,4) encoding:NSASCIIStringEncoding];
        picdataArray = [[NSMutableArray alloc] init];
        
        TAGBASE * pTagBase = nil;
        for (int n = 0; n < baseTagArray.count; n ++) {
            NSData * pCurTagData = (NSData *)[baseTagArray objectAtIndex:n];
            pTagBase = (TAGBASE *)pCurTagData.bytes;
            if (memcmp(pTagData->szTagName, pTagBase->szTagName, 4) == 0) 
                break;
        }
        
        if (pTagBase) {
            dataType = pTagBase->dataType;
            switch (dataType) {
                case DataTypeGUID:
                    if (pTagData->nTagDataSize == sizeof(GUID)) {
                        memcpy(&guidValue, (PBYTE)pTagData + sizeof(TAGDATA), sizeof(GUID));
                        return self;
                    }
                    break;
                case DataTypeString:
                {
                    PBYTE pDataTemp = (PBYTE)pTagData + sizeof(TAGDATA);
                    strValue = [[NSString alloc]initWithBytes:pDataTemp length:[COperation GetUnicodeStringLength:pDataTemp MAXLength:pTagData->nTagDataSize] encoding:NSUTF16LittleEndianStringEncoding];
                    return self;
                }
                    break;
                case DataTypeNumber:
                {
                    TAGVALUENUMMODEL * pNum = (TAGVALUENUMMODEL *)((PBYTE)pTagData + sizeof(TAGDATA));
                    numbertype = pNum->type;
                    strNumberUnit = [[NSString alloc]initWithBytes:pNum->szUnit length:16 encoding:NSUnicodeStringEncoding];
                    
                    switch (numbertype) {
                        case MNE_Int:
                            intValue = *(int *)((PBYTE)pNum + sizeof(TAGVALUENUMMODEL));
                            break;
                        case MNE_UInt:
                            uintValue = *(uint *)((PBYTE)pNum + sizeof(TAGVALUENUMMODEL));
                            break;
                        case MNE_Float:
                            fValue = *(float *)((PBYTE)pNum + sizeof(TAGVALUENUMMODEL));
                            break;
                        case MNE_Double:
                            dValue = *(double *)((PBYTE)pNum + sizeof(TAGVALUENUMMODEL));
                            break;
                    }
                    return self;
                }
                    break;
                case DataTypePicture:
                {
                    TAGVALUEPICMODEL * pNum = (TAGVALUEPICMODEL *)((PBYTE)pTagData + sizeof(TAGDATA));
                    pictureType = pNum->type;
                    PBYTE pStringBuf = (PBYTE)pNum + sizeof(TAGVALUEPICMODEL);
                    
                    NSMutableData * pStringData = nil;
                    for (int nByte = 0; nByte < pTagData->nTagDataSize - sizeof(TAGVALUEPICMODEL) - 1; nByte ++) {
                        if (pStringData == nil) {
                            pStringData = [[NSMutableData alloc] init];
                        }
                        
                        if (pStringBuf[nByte] == 0 && pStringBuf[nByte + 1] == 0) {
                            
                            if (pStringData.length != 0) {
                                
                                NSString * strPicName = [[NSString alloc]initWithBytes:pStringData.bytes length:pStringData.length encoding:NSUnicodeStringEncoding];
                                [picdataArray addObject:strPicName];
                                [strPicName release];
                            }
                            
                            nByte += 1;
                            [pStringData release];
                            pStringData = nil;
                        }
                        
                        [pStringData appendBytes:pStringBuf length:1];
                    }
                    
                    if (pStringData) {
                        [pStringData release];
                    }
                    return self;
                }
                    break;
                case DataTypeException:
                    
                    break;
            }
            return self;
        }
    }
    [self release];
    return nil;
}

-(void)dealloc
{
    [strNumberUnit release];
    [strValue release];
    [strTagKey release];
    [picdataArray release];
    [super dealloc];
}
@end

