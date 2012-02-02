//
//  TagOjb.h
//  iShowProduct
//
//  Created by 董 林 on 11-12-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIMBaseType.h"
#import "TagProtocol.h"
#import "COperation.h"

@interface TagObj : NSObject {
    NSString * strTagKey;
    
    SupportDataType     dataType;
    MobileNumbericEnum  numbertype;
    MobilePictureEnum   pictureType;
    NSString            * strNumberUnit;
    GUID                guidValue;
    NSString            * strValue;
    double              dValue;
    float               fValue;
    int                 intValue;
    uint                uintValue;
    NSMutableArray      * picdataArray;
}

@property (nonatomic,retain) NSString * strTagKey;

@property SupportDataType     dataType;
@property MobileNumbericEnum  numbertype;
@property MobilePictureEnum   pictureType;
@property (nonatomic,retain)  NSString            * strNumberUnit;
@property (nonatomic,retain)  NSString            * strValue;
@property (nonatomic,retain)  NSMutableArray      * picdataArray;
@property GUID                guidValue;
@property double              dValue;
@property float               fValue;
@property int                 intValue;
@property uint                uintValue;


-(id)initwithTagData:(TAGDATA *) pTagData BaseTag:(NSMutableArray *)baseTagArray;

@end