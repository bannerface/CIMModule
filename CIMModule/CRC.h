//
//  CRC.h
//  CIM
//
//  Created by 董 林 on 11-10-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#ifndef _ROUTINE_H_
#define _ROUTINE_H_

#import <Foundation/Foundation.h>

@interface CRCOperation : NSObject 

+ (UInt16) mGetCRC16:(void *)buffer dwLength:(UInt32)dwLength;
+ (UInt16) mGetCRC16Reversed:(void *)buffer dwLength:(UInt32)dwLength;

+ (UInt32) mGetCRC32:(void *)buffer dwLength:(UInt32)dwLength;
+ (UInt32) mGetCRC32Reversed:(void *)buffer dwLength:(UInt32)dwLength;

@end

#endif // _ROUTINE_H_