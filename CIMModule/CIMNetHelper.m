//
//  CIMNetHelper.m
//  CIM
//
//  Created by 董 林 on 11-11-2.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CIMNetHelper.h"

@implementation CIMNetHelper

- (LPCTSTR)GetStringDTNAME:(void*)pbyData dwOffset:(DWORD)dwOffset
{
    if(dwOffset == 0) return nil;
    if(((PTNAMEDAT)(pbyData + dwOffset))->wLength == 0) return nil;
    return (LPCTSTR)(((PTNAMEDAT)(pbyData + dwOffset))->chText);
}

- (WORD)GetStrLenDTNAME:(void*)pbyData dwOffset:(DWORD)dwOffset
{
    if(dwOffset == 0) return 0;
    return ((PTNAMEDAT)(pbyData + dwOffset))->wLength;
}

-(void)SetBuffer:(void*)pBuffer dwStartOffset:(DWORD)dwStartOffset dwBufferSize:(DWORD)dwBufferSize
{
	m_byBuffer = (PBYTE)pBuffer;
	m_dwStartOffset = dwStartOffset;
	m_dwOffset = m_dwStartOffset;
	m_dwSize = dwBufferSize;
}

-(void)ResetOffset:(DWORD)dwStartOffset
{
	m_dwStartOffset = dwStartOffset;
	m_dwOffset = m_dwStartOffset;
}

-(DWORD)SetOffsetDTNAME:(LPCTSTR)pszText dwBufferLen:(DWORD)dwBufferLen
{
	DWORD	dwOffset;
	DWORD	dwLength;
    
	if(pszText == NULL) dwOffset = 0;
	else
	{
		if(m_dwOffset & 1) ++m_dwOffset;
		dwOffset = m_dwOffset;
        
		dwLength = dwBufferLen;         // Strlen
		((PTNAMEDAT)(m_byBuffer + m_dwOffset))->wLength = (WORD)dwLength;
		dwLength *= sizeof(TCHAR);
        memcpy((void*)(((PTNAMEDAT)(m_byBuffer + m_dwOffset))->chText), (const void *)pszText, dwLength + sizeof(TCHAR));
		m_dwOffset += (sizeof(TNAMEDAT) + dwLength);
	}
	return dwOffset;
}

-(WORD)SetOffsetWTNAME:(LPCTSTR)pszText dwBufferLen:(DWORD)dwBufferLen
{
	return (WORD)[self SetOffsetDTNAME:pszText dwBufferLen:dwBufferLen];
}

-(DWORD)CountSizeDTNAME:(LPCTSTR)pszText dwLength:(DWORD)dwLength
{
	DWORD	dwOrigianlOffset = 0;

    dwOrigianlOffset = sizeof(TNAMEDAT);
	dwOrigianlOffset = m_dwOffset;
	if(pszText != NULL)
	{
		if(m_dwOffset & 1) ++m_dwOffset;
		m_dwOffset += (sizeof(TNAMEDAT) + dwLength * sizeof(TCHAR));       // (lstrlen(pszText) * sizeof(TCHAR))
	}
	return (m_dwOffset - dwOrigianlOffset);
}

-(DWORD)CountSizeWTNAME:(LPCTSTR)pszText dwLength:(DWORD)dwLength
{
	return [self CountSizeDTNAME:pszText dwLength:dwLength];
}

- (WORD)SetOffsetDANAME:(LPCSTR) pszText dwBufferLen:(DWORD)dwBufferLen
{
	DWORD	dwOffset;
	DWORD	dwLength;
    
	if(pszText == NULL) dwOffset = 0;
	else
	{
		if(m_dwOffset & 1) ++m_dwOffset;
		dwOffset = m_dwOffset;
		dwLength = dwBufferLen;
		((PANAMEDAT)(m_byBuffer + m_dwOffset))->wLength = (WORD)dwLength;
		memcpy((void*)(((PANAMEDAT)(m_byBuffer + m_dwOffset))->byText), (const void *)pszText, dwLength + 1);
		m_dwOffset += (sizeof(ANAMEDAT) + dwLength);
	}
	return (WORD)dwOffset;
}

- (WORD)SetOffsetWANAME:(LPCSTR) pszText dwBufferLen:(DWORD)dwBufferLen
{
    return (WORD)[self SetOffsetDANAME:pszText dwBufferLen:dwBufferLen];
}

- (DWORD)CountSizeDANAME:(LPCSTR)pszText dwLength:(DWORD)dwLength
{
	DWORD	dwOrigianlOffset;
    
	dwOrigianlOffset = m_dwOffset;
	if(pszText != NULL)
	{
		if(m_dwOffset & 1) ++m_dwOffset;
		m_dwOffset += (sizeof(ANAMEDAT) + dwLength);
	}
	return (m_dwOffset - dwOrigianlOffset);
}

-(DWORD)CountSizeWANAME:(LPCSTR)pszText dwLength:(DWORD)dwLength
{
	return [self CountSizeDANAME:pszText dwLength:dwLength];
}

@end
