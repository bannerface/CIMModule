//
//  CIMBaseType.h
//  CIM
//
//  Created by 董 林 on 11-10-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#ifndef CIM_CIMBaseType_h
#define CIM_CIMBaseType_h

#ifndef __CONDITIONALMACROS__
#include <ConditionalMacros.h>
#endif

#include <stdbool.h>

#include <sys/types.h>

#include <AvailabilityMacros.h>

#if PRAGMA_ONCE
    #pragma once
#endif

#ifdef __cplusplus
    extern "C" {
#endif
    
#pragma pack(push, 2)
    
    typedef struct {
        #define KAUTH_GUID_SIZE	16	/* 128-bit identifier */
        unsigned char g_guid[KAUTH_GUID_SIZE];
    } guid_t_Ex;
        
    typedef unsigned int                    RGBACOLOR;
    typedef unsigned long                   LONG;
    typedef guid_t_Ex                       GUID;
    typedef unsigned long                   LCID;
    typedef unichar                         TCHAR;
    typedef unsigned long long              DWORDLONG;
        
    typedef UniCharPtr                      LPCTSTR;
    typedef unsigned char*                  LPCSTR;
    typedef unsigned char                   BYTE;
    typedef unsigned char*                  PBYTE;
    typedef unsigned short                  WORD;
    
#if __LP64__
    typedef unsigned int                    DWORD;
#else
    typedef unsigned long                   DWORD;
#endif
    

#if defined(_MSC_VER) && !defined(__MWERKS__) && defined(_M_IX86)
    typedef unsigned __int64                DWORD64;
#else
    typedef unsigned long long              DWORD64;
#endif


#endif
