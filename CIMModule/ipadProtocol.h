//
//  ipadProtocol.h
//  iShowProduct
//
//  Created by 董 林 on 11-12-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#ifndef iShowProduct_ipadProtocol_h
#define iShowProduct_ipadProtocol_h

#pragma once

#pragma	pack(push, 1)

enum	NetCIMIPadCmds
{
    NCMD_MobileGet                                  = 0x0100,
    NCMD_MobilePost,
};


///////////////////////////////////////////////////////////////////////////////
// NCMD_MobileGet
//

//MGCT_GETCO,                     //取得公司信息 In:空
//MGCT_GETCONAME,                 //取得公司名称 In:公司guid

enum
{
	MGCT_GETSYSTEMINFO		= 1,	//取得系统信息 In:空
    MGCT_GETCOMPANYID,              //取得公司ID  In:空 
    MGCT_GETCOMPANYVALUE,           //取得公司信息 In:公司guid
    MGCT_GETHELPINFO,               //取得帮助信息 In:空
    
    MGCT_GETCUSTOMERS,              //取得当前登陆用户管理的客户列表        In:筛选条件
    MGCT_GETCUSTOMERINFO,           //取得已选客户的信息                   In:customerguid 
    MGCT_GETCUSTOMERORDER,          //取得已选客户的订单信息               In:customerguid
    
    MGCT_GETGROUPS,                 //根据group的id 取得group信息          In:customerguid groupguid  排序条件 升序降序判断 筛选条件
    MGCT_GETPRODUCTS,               //根据group的id 取得产品信息           In:customerguid groupguid  排序条件 升序降序判断 筛选条件
    MGCT_GETPRODUCTDETAIL,          //根据product的id 取得产品详细信息      In:customerguid productid
    MGCT_FUZZYSEARCHPRODUCTS,       //根据模糊搜索字符串 查找产品           In:customerguid 搜索字符串 排序条件 升序降序判断 筛选条件
    MGCT_GETPURCHASEDPRODUCTS,      //取得已购买产品                       In:customerguid 排序条件 升序降序判断 筛选条件
    
};
typedef BYTE MobileGetComment;  

///////////////////////////////////////////////////////////////////////////////
// NCMD_MobilePost
//
enum
{
    MPCT_ORDER = 0,
    //下单
};
typedef BYTE MobilePostComment;  

#pragma	pack(pop)

#endif
