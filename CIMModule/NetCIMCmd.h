// NetCIMCmd.h
//
// Define all the protocols of Netwroek transfer
//
#import "CIMBaseType.h"

#pragma once

#pragma	pack(push, 1)

enum	NetCIMCmds
{
	NCMD_HeartBeat									= 0,		// Heart beat
	NCMD_Security,												// Checking security
	NCMD_ReqImage,												// Request image information
	NCMD_ReqSysParam,											// Request system parameters
	NCMD_Login,													// Login
	NCMD_Logout,												// Logout
	NCMD_RequestLogout,											// Server request client to logout
	NCMD_SetSlnParam,											// Set solution parameters

};

//
// Name area strcutures
//

typedef struct	_TNAMEDAT
{
	WORD	wLength;						// Length of chText in TCHAR not including terminated zero
	TCHAR	chText[1];						// Unicode text end with terminated zero (this area must be < 64K)
} TNAMEDAT, *PTNAMEDAT;

typedef struct	_TLNAMEDAT
{
	DWORD	dwLength;						// Length of chText in TCHAR not including terminated zero
	TCHAR	chText[1];						// Unicode text end with terminated zero (this area could be >= 64K)
} TLNAMEDAT, *PTLNAMEDAT;

typedef struct	_ANAMEDAT
{
	WORD	wLength;						// Length of byText in byte not including terminated zero
	BYTE	byText[1];						// ANSI text end with terminated zero (this area must be < 64K)
} ANAMEDAT, *PANAMEDAT;

typedef struct	_ALNAMEDAT
{
	DWORD	dwLength;						// Length of byText in byte not including terminated zero
	BYTE	byText[1];						// ANSI text end with terminated zero (this area must be >= 64K)
} ALNAMEDAT, *PALNAMEDAT;

typedef WORD	WTNAME, *PWTNAME;			// WORD Offset to TNAMEDAT structure, Unicode text < 64K
typedef WORD	WTLNAME, *PWTLNAME;			// WORD Offset to TLNAMEDAT structure, Unicode text >= 64K
typedef WORD	WANAME, *PWANAME;			// WORD Offset to ANAMEDAT structure, ANSI text < 64K
typedef WORD	WALNAME, *PWALNAME;			// WORD Offset to ALNAMEDAT structure, ANSI text >= 64K

typedef DWORD	DTNAME, *PDTNAME;			// DWORD Offset to TNAMEDAT structure, Unicode text < 64K
typedef DWORD	DTLNAME, *PDTLNAME;			// DWORD Offset to TLNAMEDAT structure, Unicode text >= 64K
typedef DWORD	DANAME, *PDANAME;			// DWORD Offset to ANAMEDAT structure, ANSI text < 64K
typedef DWORD	DALNAME, *PDALNAME;			// DWORD Offset to ALNAMEDAT structure, ANSI text >= 64K

//
// Day and time structures
//

typedef union	_DATETIMEPACK
{
	struct
	{
		DWORDLONG	dlwSecond		:  6;		// Second				, Bit 00 - 05 (s)
		DWORDLONG	dlwMinute		:  6;		// Minute				, Bit 06 - 11 (m)
		DWORDLONG	dlwHour			:  5;		// Hour					, Bit 12 - 16 (h)
		DWORDLONG	dlwDay			:  5;		// Day					, Bit 17 - 21 (D)
		DWORDLONG	dlwMonth		:  4;		// Month				, Bit 22 - 25 (M)
		DWORDLONG	dlwYear			: 14;		// Year					, Bit 26 - 39 (Y)
		DWORDLONG	dlwTimeZone		: 10;		// Time zone (Minites)	, Bit 40 - 49 (z)
		DWORDLONG	dlwTimeZoneSign	:  1;		// Time zone sign		, Bit 50 - 50 (Z), LocalTime = UTC + Timezone
		DWORDLONG	dlwDayLight		:  1;		// Daylight saving time	, Bit 51 - 51 (d)
		DWORDLONG	dlwFiller		: 12;		// Reserved				, Bit 52 - 63 (r)
	};
		DWORDLONG	dlwDateTime;				// DateTime
} DATETIMEPACK, *PDATETIMEPACK;

#define	TIMEZONEOFFSET		16

// Bit
// 63 62 61 60 59 58 57 56 55 54 53 52 51 50 49 48 47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
//																																												  s  s  s  s  s  s
//																																								m  m  m  m  m  m
//																																				 h  h  h  h  h
//																																  D  D  D  D  D
//																													  M  M  M  M
//																			Y  Y  Y  Y  Y  Y  Y  Y  Y  Y  Y  Y  Y  Y
//											  z  z  z  z  z  z  z  z  z  z
//										   Z
//									    d
//  r  r  r  r  r  r  r  r  r  r  r  r

///////////////////////////////////////////////////////////////////////////////
// NCMD_HeartBeat: Heart beat command
// 
//	Send: Header only
//		wCommand = NCMD_HeartBeat
//		byComment = 0
//		byFlags = NWPH_BEGINNING | NWPH_ENDING | NWPH_INTERNAL_USE
//

///////////////////////////////////////////////////////////////////////////////
// NCMD_Security: Initialization security command
// 
//	Send:
//		wCommand = NCMD_Security
//		byComment = 0
//		byFlags = NWPH_BEGINNING | NWPH_ENDING | NWPH_INTERNAL_USE [| NWPH_COMMAND_RETURN]
//

enum
{
	SCIZ_VERIFY_CERTIFICATE_DATA		= 0,		// Send verify certificate data to other side
	SCIZ_SESSIONKEY_DATA,							// Send session key data to other side
	
	SCIZ_SIGN_ERROR						= 0x80,		// Sign certificate error on the other side
	SCIZ_SESSIONKEY_ERROR,							// Create session key data error on the other side
};
typedef BYTE SecurityComment;
    
//
// SCIZ_VERIFY_CERTIFICATE_DATA:
//		Client Site: Send data need to be verified to server.
//		Server Site: Send back the data had been signed. (with NWPH_COMMAND_RETURN flag on)
//					 If error occur,
//						send SCIZ_SIGN_ERROR Comment back to client (with NWPH_COMMAND_RETURN flag on)
//						the data field is ERRORCODE structure
//
// SCIZ_SESSIONKEY_DATA:
//		Client Site: Send encrypted data need to be as session key to server.
//		Server Site: No data field, just indicated to client that server had created seession key successfully (with NWPH_COMMAND_RETURN flag on).
//					 If error occur,
//						send SCIZ_SESSIONKEY_ERROR Comment back to client (with NWPH_COMMAND_RETURN flag on)
//						the data field is ERRORCODE structure
//
//
//	typedef struct
//	{
//		DWORD		dwErrorCode;						// Error code
//		BYTE		byErrorSource;						// Error source
//		BYTE		byFillers[3];						// Dummy, no used
//	} ERRORCODE, *PERRORCODE;
//
//	#define	ERRSRC_NONE				0					// This structure is no used
//	#define	ERRSRC_WINDOWS			1					// Windows error code
//	#define	ERRSRC_WINSOCK			2					// Winsock2 error code
//	#define	ERRSRC_LOCAL			3					// Local error, Local error code
//	#define	ERRSRC_SERVER			4					// Server error, Local error code
//	#define	ERRSRC_CUSTOM			5					// Custom error code
//	#define	ERRSRC_EXCEPTION		6					// Win32 exception
//	#define	ERRSRC_DIRECT2D			7					// Direct2D error code
//	#define	ERRSRC_GDIPLUS			8					// GDI+ error code
//	#define	ERRSRC_ZLIB				9					// Zlib error code
//	#define	ERRSRC_CRYPTOGRAPHY		10					// Cryptography API error code (Same as Windows error code)
//	#define	ERRSRC_WMI				11					// WMI error code ((Same as Windows error code)
//

///////////////////////////////////////////////////////////////////////////////
// NCMD_Login: User Login command
//
//	Send:
//		wCommand = NCMD_Login
//		byComment = LGICT_LOGIN (0)
//		byFlags = NWPH_BEGINNING | NWPH_ENDING | NWPH_ENCRIPTION [ | NWPH_USER_DATA]
//
//	Will receive after sending this command:
//		wCommand = NCMD_Login
//		byComment = LGICT_RESULT

typedef struct	_NDATLogin
{
	LCID			lcidUILanguage;					// Default language ID of solution
	WTNAME			wMachineName;					// Offset to client machine name
	WTNAME			wComputerDescription;			// Offset to computer description
	WTNAME			wUsername;						// Offset to user name
	WTNAME			wPassword;						// Offset to password
	WANAME			wInternalIP;					// Offset to client internal IP address
} NDATLogin, *PNDATLogin;

//	Receive:
//		wCommand  = NCMD_Login
//		byComment = LGCT_RESULT (2)
//		byFlags   = NWPH_BEGINNING | NWPH_ENDING | NWPH_ENCRIPTION | NWPH_COMMAND_RETURN [ | NWPH_USER_DATA]
//
//		Data structures:
//			NDATLoginInfo
//			if byResult == NLGR_SUCCESSFUL (0)
//				another packet of command will be returned with byComment == LGCT_SOLUTIONS (4)
//
//			if byResult == NLGR_LOGIN_ANOTHER_PLACE (1),
//				another packet of command will be returned with byComment == LGCT_WAITINFO (3)
//					and then packet of command will be returned with byComment == LGCT_SOLUTIONS (4) (Login successful)
//					or then packet of command will be returned with byComment == LGCT_ABORT (5) (Reject by user in another place)
//				or packet of command will be returned with byComment == LGICT_ABORT_WITH_INFO (6) : The third people would like to login with same username, abort directly.

///////////////////////////////////////////////////////////////////////////////
// NCMD_Login: User Reconnect command
//
//	Send:
//		wCommand  = NCMD_Login
//		byComment = LGICT_RELOGIN (1)
//		byFlags   = NWPH_BEGINNING | NWPH_ENDING | NWPH_ENCRIPTION [ | NWPH_USER_DATA]
//
//	Will receive after sending this command:
//		wCommand  = NCMD_Login
//		byComment = LGICT_RELOGIN_STATUS or LGICT_ABORT_WITH_INFO

typedef struct	_NDATReLogin
{
	GUID			guidWorkspace;					// Workspace GUID
	WTNAME			wComputerDescription;			// Offset to computer description
	WANAME			wInternalIP;					// Offset to client internal IP address
} NDATReLogin, *PNDATReLogin;

//	Receive:
//		wCommand  = NCMD_Login
//		byFlags   = NWPH_BEGINNING | NWPH_ENDING | NWPH_ENCRIPTION | NWPH_COMMAND_RETURN [ | NWPH_USER_DATA]
//		byComment = LGICT_RELOGIN_STATUS (7)
//		or
//		byComment == LGICT_ABORT_WITH_INFO (6)	-- Another same user online

enum
{
	LGICT_LOGIN							= 0,		// Login
	LGICT_RELOGIN,									// Relogin

	LGICT_RESULT,									// Return login result
	LGICT_WAITINFO,									// Return login wait information for another station to take action
	LGICT_SOLUTIONS,								// Return solutions information
	LGICT_ABORT,									// Request to abort login procedure
	LGICT_ABORT_WITH_INFO,							// Request to abort login procedure, and which station to abort this login procedure
	LGICT_RELOGIN_STATUS,							// Relogin status
};
typedef BYTE LogInComment;

enum
{
	NLGR_SUCCESSFUL						= 0,		// Successful
	NLGR_LOGIN_ANOTHER_PLACE,						// Login in another place
	NLGR_AUTHENTICATION_ERROR,						// Authentication error
	NLGR_ACCOUNT_DISABLE,							// Account disable
	NLGR_DUPLICATED_ACCOUNT,						// Duplicated account
	NLGR_ADNAME_NOTFOUND,							// Active Directory name not found
	NLGR_WORKSPACE_NOTFOUND,						// Workspace not found
};
typedef BYTE NetLogInResult;

enum
{
	NLGR_DATABASE						= 0,		// CIM Database
	NLGR_WINDOWS,									// Windows authentication
	NLGR_DOMAIN,									// Active Directory authentication
};
typedef BYTE NetLogInAuthSource;

//	Receive: two command share the same structure
//		wCommand = NCMD_Login
//		byComment = LGCT_RESULT (2)
//		byFlags = NWPH_BEGINNING | NWPH_ENDING | NWPH_ENCRIPTION | NWPH_COMMAND_RETURN [ | NWPH_USER_DATA]
//
//		Return login status
//
//		wCommand = NCMD_Login
//		byComment = LGCT_ABORT (5)
//		byFlags = NWPH_BEGINNING | NWPH_ENDING | NWPH_ENCRIPTION | NWPH_COMMAND_RETURN [ | NWPH_USER_DATA]
//
//		Return another station that abort this login request

typedef struct	_NDATLoginInfo
{
	GUID				guidWorkspace;				// Workspace GUID
	WTNAME				wServerMachineName;			// Offset to server machine name
	WTNAME				wActiveDirectoryName;		// Offset to Active Directory name
	WANAME				wServerIP;					// Offset to server IP address
	WANAME				wClientIP;					// Offset to client IP address
	NetLogInResult		byResult;					// Result of login
	NetLogInAuthSource	byAuthSource;				// Authentication source
	BYTE				byFiller[2];
} NDATLoginInfo, *PNDATLoginInfo;

//	Receive: two command share the same structure
//		wCommand = NCMD_Login
//		byComment = LGCT_WAITINFO (3)
//		byFlags = NWPH_BEGINNING | NWPH_ENDING | NWPH_ENCRIPTION | NWPH_COMMAND_RETURN [ | NWPH_USER_DATA]
//
//		Return another station waiting inforamtion
//
//		wCommand = NCMD_Login
//		byComment = LGICT_ABORT_WITH_INFO (6)
//		byFlags = NWPH_BEGINNING | NWPH_ENDING | NWPH_ENCRIPTION | NWPH_COMMAND_RETURN [ | NWPH_USER_DATA]
//
//		Return another station that abort this login request, wTimeToWait will be 0

typedef struct	_NDATLoginWaitInfo
{
	DATETIMEPACK	dtLoginTime;					// Login time of other side
	WTNAME			wMachineName;					// Offset to client machine name of other side
	WTNAME			wComputerDescription;			// Offset to computer description of other side
	WTNAME			wUsername;						// Offset to user name of other side
	WANAME			wInternalIP;					// Offset to client internal IP address of other side from client supply inforamtion
	WANAME			wInternalIPServer;				// Offset to client internal IP address of other side from server
	WORD			wTimeToWait;					// Number of seconds to wait the another station to take action
} NDATLoginWaitInfo, *PNDATLoginWaitInfo;

// Internal structure

typedef struct	_NDATSLNBASE
{
	GUID			guidDatabase;					// Database GUID
	DTNAME			dwSolutionName;					// Offset to solution name
	DTNAME			dwAliasName;					// Offset to alias name
	DWORD			dwStyle;						// Style of this solution
} NDATSLNBASE, *PNDATSLNBASE;

//		wCommand = NCMD_Login
//		byComment = LGCT_SOLUTIONS (4)
//		byFlags = NWPH_BEGINNING | NWPH_ENDING | NWPH_ENCRIPTION | NWPH_COMMAND_RETURN [ | NWPH_USER_DATA]
//
//		Return solutions

typedef struct	_NDATSLNHEADER
{
    GUID            guidLoginUser;
	DWORD			dwNumberOfSolutions;			// Number of solutions
	DWORD			dwNumberOfLCIDs;				// Number of LCIDs
	DWORD			dwLCIDsOffset;					// Offset to LCID list
	NDATSLNBASE		slnSolutions[1];				// Solutions
} NDATSLNHEADER, *PNDATSLNHEADER;

//	Receive:
//		wCommand = NCMD_Login
//		byComment = LGICT_RELOGIN_STATUS (7)
//		byFlags = NWPH_BEGINNING | NWPH_ENDING | NWPH_ENCRIPTION | NWPH_COMMAND_RETURN [ | NWPH_USER_DATA]
//
//		Return relogin status

typedef struct	_NDATRELOGINOK
{
	NetLogInResult		byResult;					// Result of login
	BYTE				byFiller;					// No used
	WANAME				wClientIP;					// Offset to client IP address
} NDATRELOGINOK, *PNDATRELOGINOK;


///////////////////////////////////////////////////////////////////////////////
// NCMD_RequestLogout: Request user to logout command
//
//	Receive at client side
//		wCommand = NCMD_RequestLogout
//		byComment = 0
//		byFlags = NWPH_BEGINNING | NWPH_ENDING | NWPH_ENCRIPTION [ | NWPH_USER_DATA]

enum
{
	REQLOGOUT_KEEP					= 1,			// Keep connection status
};
typedef BYTE ReqLogOutComment;    

typedef struct	_NDATRtLogout
{
	WTNAME			wMachineName;					// Offset to client machine name of other side
	WTNAME			wComputerDescription;			// Offset to computer description of other side
	WTNAME			wUsername;						// Offset to user name of other side
	WANAME			wInternalIP;					// Offset to client internal IP address of other side
	WANAME			wInternalIPServer;				// Offset to client internal IP address of other side from server
	WORD			wTimeout;						// Number of seconds to wait the client to decide, if = 0, force closing.
	GUID			guidWorkspace;					// Workspace GUID
	GUID			guidNewWorkspace;				// Workspace GUID from new client
} NDATRtLogout, *PNDATRtLogout;

//	Send by client
//		wCommand = NCMD_RequestLogout
//		byComment = 1
//		byFlags = NWPH_BEGINNING | NWPH_ENDING | NWPH_ENCRIPTION | NWPH_COMMAND_RETURN [ | NWPH_USER_DATA]

typedef struct	_NDATRtLogoutRet
{
	GUID			guidWorkspace;					// Workspace GUID
	GUID			guidNewWorkspace;				// Workspace GUID from new client
} NDATRtLogoutRet, *PNDATRtLogoutRet;


///////////////////////////////////////////////////////////////////////////////
// NCMD_Logout: Logout command
//
//		wCommand = NCMD_Logout
//		byComment = 0	 -- Normal
//				  = 0xff -- Abort
//		byFlags = NWPH_BEGINNING | NWPH_ENDING [ | NWPH_USER_DATA]
//
//		Return complete header of original packet
//

enum
{
	LGOCT_NORMAL						= 0,		// Normal logout
	LGOCT_ABORT							= 0xff,		// Abort logout
};
typedef BYTE LogOutComment;     

typedef struct	_NDATLogout
{
	GUID			guidWorkspace;					// Workspace GUID
} NDATLogout, *PNDATLogout;


///////////////////////////////////////////////////////////////////////////////
// NCMD_ReqImage: Request Image List
//
//	Send:
//		wCommand = NCMD_ReqImage
//		byComment = RIC_SYSTEM		-- Data section: NDATIMGFROMSYS structure
//					RIC_SOLUTION	-- Data section: NDATIMGFROMSLN structure
//					RIC_DATAB		-- Data section: NDATIMGFROMDAT structure
//		byFlags = NWPH_BEGINNING | NWPH_ENDING [ | NWPH_USER_DATA]
//
//
//	Will receive after sending this command:
//		wCommand = NCMD_ReqImage
//		byComment = RIC_IMAGELIST	-- NDATIMGNAMELIST structure return
//					RIC_IMAGEDATA	-- Image data return in NDATIMGDATA format
//		byFlags = NWPH_BEGINNING | NWPH_ENDING | NWPH_COMMAND_RETURN [ | NWPH_USER_DATA]
//

enum
{
	RIC_GETIMGLIST					= 1,			// Request image from system, no data, only header
	RIC_GETIMGDATA,									// Request image from solution

	RIC_GETIMGLISTERROR				= 0x81,			// Get image list error, no data, only header
	RIC_GETIMGDATAERROR,							// Get image data error, no data, only header
};
typedef BYTE ReqImageComment;  
    
typedef struct	_NDATIMGFMTLST
{
	GUID			guidDatabase;					// Database GUID
	GUID			guidTable;						// Table GUID
	GUID			guidField;						// Field GUID
	GUID			guidRecord;						// Record GUID
} NDATIMGFMTLST, *PNDATIMGFMTLST;

typedef struct	_NDATIMGFROMDAT
{
	DWORD			dwSrcSize;						// Size of this image in source, if this field is zero, then image list will return
	DWORD			dwSrcOffset;					// Offset of this image in source
	NDATIMGFMTLST	ndatBaseFmt;					// Base GUID of image
} NDATIMGFROMDAT, *PNDATIMGFROMDAT;

typedef struct _NDATIMGTEXT
{
	DTNAME			dwTextAreaName;					// Text area name
	DTNAME			dwNameOffset;					// Image Name of this image
	DWORD			dwImageID;						// Image ID
	DTNAME			dwFontName;						// Window font name
	DWORD			dwFontPixelSize;				// Text font size in pixels
	RGBACOLOR		colorText;						// Solid color of text
	RGBACOLOR		colorTextShadow;				// Solid color of text shadow
	LONG			nTopGap;						// Number of pixels on top of book label text
	LONG			nLeftGap;						// Number of pixels on left of book label text
	LONG			nRightGapWidth;					// Number of pixels on right of book label text in negative form (<= 0), or width of text area if this value > 0
	LONG			nBottomGapHeight;				// Number of pixels on right of book label text in negative form (<= 0), or height of text area if this value > 0
	WORD			wFontFormat;					// Text format -- 4: Bold, 8: Italic
	BYTE			byXAlignment;					// Text alignment -- 0: Left, 1: Center, 2: Right
	BYTE			byYAlignment;					// Text alignment -- 0: Top, 1: Center, 2: Bottom
} NDATIMGTEXT, *PNDATIMGTEXT;

typedef struct	_NDATIMGINFO
{
	DWORD			dwWidth;						// Width of this image
	DWORD			dwHeight;						// Height of this image
	DTNAME			dwNameOffset;					// Name index of this image, same image name must point to same offset
	DWORD			dwSrcOffset;					// Offset of this image in source
	DWORD			dwSrcSize;						// Size of this image in source
	DWORD			dwImageID;						// Image ID
	DWORD			dwImageCRC;						// Image CRC
} NDATIMGINFO, *PNDATIMGINFO;

typedef struct	_NDATIMGNAMELIST
{
	DWORD			dwTotalImages;					// Number of images in the list
	DWORD			dwTotalImgTexts;				// Number of image text array in the list
	DWORD			dwImgTextOffset;				// Offset to image text area
	NDATIMGINFO		ndatImgInfo[1];					// Array of image information (NDATIMGINFO)
													// Array of image text (NDATIMGTEXT)
} NDATIMGNAMELIST, *PNDATIMGNAMELIST;


///////////////////////////////////////////////////////////////////////////////
// NCMD_ReqSysParam: Request System Parameters
//
//	Send:
//		wCommand = NCMD_GetSysParams
//		byComment = RSP_ACCBOOKPARAMS	-- Request account books window system parameters
//		byFlags = NWPH_BEGINNING | NWPH_ENDING [ | NWPH_USER_DATA]
//
//	Will receive after sending this command:
//		wCommand = RSP_ACCBOOKPARAMS
//		byComment = Same as sender byComment
//		byFlags = NWPH_BEGINNING | NWPH_ENDING | NWPH_COMMAND_RETURN [ | NWPH_USER_DATA]
//

enum
{
	RSP_SYSWINPARAMS			= 0,				// Request account books frame parameters, no data, only header
	RSP_ACCBOOKPARAMS,								// Request account books parameters, no data, only header
	RSP_ACCBOOKICONPACKAGES,						// Request account books icon package parameters, no data, only header
	RSP_SLNSYSWINPARAMS,							// Request account window frame parameters, data contain a GUID of database
	RSP_SLNICONPACKAGES,							// Request account window icon packages, data contain a GUID of database
	RSP_SLNTABPARAMS,								// Request account window tab control layout parameters, data contain a GUID of database

	RSP_ERROR_FLAG				= 0x80,				// Error flag

	RSP_SYSWINPARAMS_ERROR		= 0x80,				// Error: Request account books frame parameters, no data, only header
	RSP_ACCBOOKPARAMS_ERROR,						// Error: Request account books parameters, no data, only header
	RSP_ACCBOOKICONPACKAGES_ERROR,					// Error: Request account books icon package parameters, no data, only header
	RSP_SLNSYSWINPARAMS_ERROR,						// Error: Request account window frame parameters, data contain a GUID of database
	RSP_SLNICONPACKAGES_ERROR,						// Error: Request account window icon packages, data contain a GUID of database
	RSP_SLNTABPARAMS_ERROR,							// Error: Request account window tab control layout parameters, data contain a GUID of database
};
typedef BYTE ReqSystemParamComment;      

typedef struct	_SYSWINLAYOUTPARAM
{
	DWORD			dwInitWndWidth;					// Beginning Window width
	DWORD			dwInitWndHeight;				// Beginning Window height
	DWORD			dwBorderSize;					// Border line thickness
	DWORD			dwBorderShadowSize;				// Border shadow line thickness
	DWORD			dwCaptionHeight;				// Caption height including two side border
	DWORD			dwBasementHeight;				// Basement height including two side border
	DWORD			dwBorderHitTestWidth;			// Thickness around border for mouse hit test to size a window
	DWORD			dwSysIconTopGap;				// Number of pixels between top border and windows action icon top edge (Not including border and icon edge)
	DWORD			dwSysIconRightGap;				// Number of pixels between right border and windows action icon right edge (Not including border and icon edge)
	LONG			nSysIconGap;					// Number of pixels between window action icon

	DWORD			dwTitleTextFontPixelSize;		// Window title font size in pixels
	DWORD			dwTitleTextTopGap;				// Number of pixels between top border and window title text (Not including border and text edge)
	DWORD			dwTitleTextLeftGap;				// Number of pixels between left border and window title text (Not including border and text edge)
	DWORD			dwTitleTextRightGap;			// Number of pixels between Right border and window title text (Not including border and text edge)
	WORD			wTitleTextFontFormat;			// Book label Text format -- 4: Bold, 8: Italic
	BYTE			dwTitleTextXAlignment;			// Text alignment -- 0: Left, 1: Center, 2: Right
	BYTE			byTitleTextReserve;

	DTNAME			dwTitleTextFontName;			// Window font name

	RGBACOLOR		colorBorder;					// Solid color of border
	RGBACOLOR		colorBorderShadow;				// Solid color of border shadow
	RGBACOLOR		colorText;						// Solid color of text
	RGBACOLOR		colorTextShadow;				// Solid color of text shadow
	RGBACOLOR		colorActiveCaptionTop;			// Gradient Color of caption in top position of active window status
	RGBACOLOR		colorActiveCaptionBottom;		// Gradient Color of caption in bottom position of active window status
	RGBACOLOR		colorActiveBasementTop;			// Gradient Color of basement in top position of active window status
	RGBACOLOR		colorActiveBasementBottom;		// Gradient Color of basement in bottom position of active window status
	RGBACOLOR		colorInactiveCaptionTop;		// Gradient Color of caption in top position of inactive window status
	RGBACOLOR		colorInactiveCaptionBottom;		// Gradient Color of caption in bottom position of inactive window status
	RGBACOLOR		colorInactiveBasementTop;		// Gradient Color of basement in top position of inactive window status
	RGBACOLOR		colorInactiveBasementBottom;	// Gradient Color of basement in bottom position of inactive window status
} NDATSYSWINLAYPARAM, *PNDATSYSWINLAYPARAM;

typedef struct	_BOOKWINLAYOUTPARAM
{
	DWORD			dwBookGap;						// Number of pixels between books
	DWORD			dwBookTopGap;					// Number of pixels between top edge of level and a book
	DWORD			dwBookLeftGap;					// Number of pixels between left edge of level and a book
	DWORD			dwBookRightGap;					// Number of pixels between right edge of level and a book
	DWORD			dwBookMoveDownHeight;			// Number of pixels should move down when book has been selected
	DWORD			dwLevelDividerHeight;			// Number of pixels in one level of bookshelf
	DWORD			dwLevelTopShadowHeight;			// Number of pixels of shadow height in top edge of each level of bookshelf
	DWORD			dwLevelLeftShadowWidth;			// Number of pixels of shadow width in left edge of each level of bookshelf
	DWORD			dwLevelRightShadowWidth;		// Number of pixels of shadow width in right edge of each level of bookshelf

	LONG			nBookHorizontalGap;				// Number of pixels + 1 of horizontal gap between window side and start of icons,
													//	Negative value count from right side, Positive value count from left side, 0 = Center in horizontal direction
	LONG			nBookVerticalGap;				// Number of pixels + 1 of vertical gap between window side and start of icons,
													//	Negative value count from bottom side, Positive value count from top side, 0 = Center in vertical direction

	RGBACOLOR		colorUpperShadowTop;			// Gradient Color of upper shadow top postion for each level
	RGBACOLOR		colorUpperShadowBottom;			// Gradient Color of upper shadow bottom postion for each level
	RGBACOLOR		colorLeftShadowLeft;			// Gradient Color of left shadow left postion for each level
	RGBACOLOR		colorLeftShadowRight;			// Gradient Color of left shadow right postion for each level
	RGBACOLOR		colorRightShadowLeft;			// Gradient Color of right shadow left postion for each level
	RGBACOLOR		colorRightShadowRight;			// Gradient Color of right shadow right postion for each level
	RGBACOLOR		colorBookTransparence;			// Transparence of book
} NDATBOOKWINLAYPARAM, *PNDATBOOKWINLAYPARAM;

typedef struct
{
	DTNAME			dwIconName;						// Icon name
	DTNAME			dwTipText;						// Tool tip text
	DWORD			dwPackageID;					// Package ID
	DWORD			dwGroupID;						// Button group ID, = 0 for single button, = -1 for splitter
													//	if Bit 31 = 1, this group allows no button be pressed.
	LONG			nButtonID;						// Button ID, Button with same Button ID occupy one location only
	DWORD			dwActionID;						// Button action ID
	LONG			nHorizontalGap;					// Number of pixels + 1 of horizontal gap between side and start of icons,
													//	Negative value count from right side, Positive value count from left side, 0 = Center in horizontal direction
	LONG			nVerticalGap;					// Number of pixels + 1 of vertical gap between side and start of icons,
													//	Negative value count from bottom side, Positive value count from top side, 0 = Center in vertical direction
} NDATICOBUTTON, *PNDATICOBUTTON;

typedef struct
{
	DWORD			dwCount;						// Number of icons in this package
	DWORD			dwPanelPosition;				// Panael position (= 0 upper panel, = 1 bottom panel)
	DWORD			dwPackageID;					// Package ID
	LONG			nHorizontalGap;					// Number of pixels + 1 of horizontal gap between window side and start of icons,
													//	Negative value count from right side, Positive value count from left side, 0 = Center in horizontal direction
	LONG			nVerticalGap;					// Number of pixels + 1 of vertical gap between window side and start of icons,
													//	Negative value count from bottom side, Positive value count from top side, 0 = Center in vertical direction
	DWORD			dwIconGap;						// Number of pixels between icons
} NDATICOPACKAGE, *PNDATICOPACKAGE;

typedef struct
{
	DWORD			dwPackagesCount;				// Number of icon packages
	DWORD			dwIconsCount;					// Number of icons
	NDATICOPACKAGE	packages[1];					// Array of icon packages
} NDATACCBOOKPARAM, *PNDATACCBOOKPARAM;


///////////////////////////////////////////////////////////////////////////////
// NCMD_SetSlnParam: Set solution parameters
//
//	Send:
//		wCommand = NCMD_SetSlnParam
//		byComment = see enum SetSlnParamComment
//		byFlags = NWPH_BEGINNING | NWPH_ENDING [ | NWPH_USER_DATA]
//
//
//	Will receive after sending this command:
//		wCommand = NCMD_SetSlnParam
//		byComment = 1 -- OK, 0 -- Failed
//		byFlags = NWPH_BEGINNING | NWPH_ENDING | NWPH_COMMAND_RETURN [ | NWPH_USER_DATA]
//

enum
{
	SSP_STYLE					= 0,				// Set solution style

	SSP_STYLE_ERROR				= 0x80,				// Set solution style error
};
typedef BYTE SetSlnParamComment;      

typedef struct	_NDATSLNSTYLE
{
	GUID			guidDatabase;					// Database GUID
	DWORD			dwStyle;						// Style
} NDATSLNSTYLE, *PNDATSLNSTYLE;


///////////////////////////////////////////////////////////////////////////////
// NCOBJ_Solution: Get Solution Information
//
//	Send:
//		wCommand = NCOBJ_Solution
//		byComment = SOC_GETSLNSTRUCTURE	-- Get solution structure
//		byFlags = NWPH_BEGINNING | NWPH_ENDING | NWPH_ENCRIPTION | NWPH_COMPRESSION [ | NWPH_USER_DATA]
//		Data: GUID of account database
//
//	Will receive after sending this command:
//		wCommand = NCOBJ_Solution
//		byComment = Same as sender byComment if successful
//					sender byComment | 0x80 if error occur (return error structure)
//		byFlags = NWPH_BEGINNING | NWPH_ENDING | NWPH_ENCRIPTION | NWPH_COMPRESSION | NWPH_COMMAND_RETURN [ | NWPH_USER_DATA]
//

enum
{
	SOC_GETSLNSTRUCTURE			= 0,				// Get solution structure,
													//	Send data	: GUID of account database
													//	Return data	: typedef struct _CIMBaseSolution data structure (check CIMBase.h)

	SOC_GETVIEW,									// Get view structure,
													//	Send data	: typedef struct _REQUESTVIEW
													//	Return data	: typedef struct _CIMBaseView data structure (check CIMBase.h)

	SOC_GETSLNCSS,									// Get solution CSS data
													//	Send data	: GUID of account database
													//	Return data	: typedef struct _CIMSlnCSS data structure (check CIMBase.h)

	SOC_GETRECORD,									// Get specific record
													//	Send data	: typedef struct _RecordSpecify
													//	Return data	: typedef struct _RecordData

	SOC_UPDATERECORD,								// Update specific record
													//	Send data	: typedef struct _RecordData

	SOC_DELETERECORD,								// Delete specific record
													//	Send data	: typedef struct _RecordSpecify

	SOC_FORCEDELETERECORD,							// Force delete specific record
													//	Send data	: typedef struct _RecordSpecify

	SOC_CHECKDELETERECORD,							// Check delete specific record
													//	Send data	: typedef struct _RecordSpecify

	SOC_LOCKRECORD,									// Lock record
													//	Send data	: typedef struct _RecordSpecify

	SOC_UNLOCKRECORD,								// Unlock record
													//	Send data	: typedef struct _RecordSpecify

	SOC_ERROR_FLAG				= 0x80,				// Error flag
	
	SOC_GETSLNSTRUCTURE_ERROR	= 0x80,				// Get solution structure error
	SOC_GETVIEW_ERROR,								// Get view error
	SOC_GETSLNCSS_ERROR,							// Get solution CSS data error
};
typedef BYTE SlnObjComment;      

typedef struct	_REQUESTVIEW
{
	GUID			guidDatabase;					// Guid of this database
	DTNAME			dwViewName;						// Name of request view
} NDATREQVIEW, *PNDATREQVIEW;

typedef struct	_TableFields
{
	GUID			guidTable;						// Guid of this table
	DWORD			dwNumFields;					// Number of fields
	DWORD			dwFieldsOffset;					// Offset to array of fields Guid
} NDATTBLFIELDS , *PNDATTBLFIELDS;

typedef struct	_RecordsData
{
	GUID			guidDatabase;					// Guid of this database
	DWORD			dwNumRecords;					// Number of records
	DWORD			dwBytesPerReocrd;				// Number of bytes in a record
	DWORD			dwRecordOffset;					// Offset to array of data record
	DWORD			dwNumTableDefs;					// Number of table-fields definitions
	NDATTBLFIELDS	listFields[1];					// Array of table-fields definitions
} NDATRECORDSDATA, *PNDATRECORDSDATA;

typedef struct	_RecordSpecify
{
	GUID			guidDatabase;					// Guid of this database
	GUID			guidTable;						// Guid of table
	GUID			guidRecord;						// Guid of record
} NDATRECORDSPE, *PNDATRECORDSPE;

typedef struct	_RecordItem
{
	DWORD			dwBytesPerReocrd;				// Number of bytes in a record
	DWORD			dwRecordOffset;					// Offset to record data
	GUID			guidField[1];					// Data fields GUID
} NDATRECORDITEM, *PNDATRECORDITEM;

typedef struct	_RecordChild
{
	GUID			guidField;						// Child field GUID
	DWORD			dwNumRecords;					// Number of records
	DWORD			dwFieldsOffset;					// Offset to typedef struct	_RecordItems
	DWORD			dwChildCount;					// Number of grand child fileds
	DWORD			dwChildOffset[1];				// Offset to self: typedef struct _RecordChild
} NDATRECORDCHILD, *PNDATRECORDCHILD;

typedef struct	_RecordData
{
	NDATRECORDSPE	spcRecord;						// Specific record
	DWORD			dwFieldsOffset;					// Offset to typedef struct	_RecordItems
	DWORD			dwChildCount;					// Number of child fileds
	DWORD			dwChildOffset[1];				// Offset to typedef struct _RecordChild
} RECORDDATA, *PRECORDDATA;

#pragma	pack(pop)
