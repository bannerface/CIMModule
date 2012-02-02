//
//  TagProtocol.h
//  iShowProduct
//
//  Created by 董 林 on 11-12-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#ifndef iShowProduct_TagProtocol_h
#define iShowProduct_TagProtocol_h

typedef enum _SupportDataType
{
    DataTypeGUID = 0,
    DataTypeString,
    DataTypeNumber,
    DataTypePicture,
    DataTypeException,
}SupportDataType;

typedef struct	_tagBase
{
    char            szTagName[4];
    NSString        * strDesc;
    SupportDataType dataType;
} TAGBASE, *PTAGBASE;

typedef struct _commentBase
{
    NSInteger      nCommentID;
    NSMutableArray * strCommentKey;
}COMMENTBASE,*PCOMMENTBASE;

typedef enum _MobileNumbericEnum
{
    MNE_Int = 1,
    MNE_UInt,
    MNE_Float,
    MNE_Double,
}MobileNumbericEnum;

typedef struct _tagValueNumModel
{
    MobileNumbericEnum type;
    unichar            szUnit[8];
}TAGVALUENUMMODEL,*PTAGVALUENUMMODEL;

typedef enum _MobilePictureEnum
{
    MPE_BMP = 1,
    MPE_JPG,
    MPE_PNG,
}MobilePictureEnum;

typedef struct _tagValuePicModel
{
    uint              nPicCount;
    MobilePictureEnum type;
}TAGVALUEPICMODEL,*PTAGVALUEPICMODEL;

typedef struct _setData
{
    GUID guidSolution;
    uint nRowCount;
}SETDATA,*PSETDATA;

typedef struct _tagData
{
    char szTagName[4];
    uint nTagDataSize;
}TAGDATA,*PTAGDATA;

#endif
