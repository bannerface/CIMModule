//
//  CIMNetHelper.h
//  CIM
//
//  Created by 董 林 on 11-11-2.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIMBaseType.h"
#import "NetCIMCmd.h"
#import "wchar.h"

@interface CIMNetHelper : NSObject
{
    PBYTE   m_byBuffer;
    DWORD   m_dwStartOffset;
    DWORD   m_dwOffset;
    DWORD   m_dwSize;
}

- (LPCTSTR)GetStringDTNAME:(void*)pbyData dwOffset:(DWORD)dwOffset;
- (WORD)GetStrLenDTNAME:(void*)pbyData dwOffset:(DWORD)dwOffset;

- (void)SetBuffer:(void*)pBuffer dwStartOffset:(DWORD)dwStartOffset dwBufferSize:(DWORD)dwBufferSize;
- (void)ResetOffset:(DWORD)dwStartOffset;

- (DWORD)SetOffsetDTNAME:(LPCTSTR) pszText dwBufferLen:(DWORD)dwBufferLen;
- (WORD)SetOffsetWTNAME:(LPCTSTR) pszText dwBufferLen:(DWORD)dwBufferLen;
- (DWORD)CountSizeWTNAME:(LPCTSTR) pszText dwLength:(DWORD)dwLength;
- (DWORD)CountSizeDTNAME:(LPCTSTR)pszText dwLength:(DWORD)dwLength;

- (WORD)SetOffsetDANAME:(LPCSTR) pszText dwBufferLen:(DWORD)dwBufferLen;
- (WORD)SetOffsetWANAME:(LPCSTR) pszText dwBufferLen:(DWORD)dwBufferLen;
- (DWORD)CountSizeDANAME:(LPCSTR)pszText dwLength:(DWORD)dwLength;
- (DWORD)CountSizeWANAME:(LPCSTR)pszText dwLength:(DWORD)dwLength;


@end
