//
//  CIMViewController.h
//  CIMModule
//
//  Created by 林 董 on 12-2-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CIMNetEngine.h"
#import "CIMDBEngine.h"

@interface CIMViewController : UIViewController
{
    CIMNetEngine * pNetEngine;
    CIMDBEngine * pDbEngine;
    
    //1234
}

@property (nonatomic,retain) CIMNetEngine * pNetEngine;
@property (nonatomic,retain) CIMDBEngine * pDbEngine;
@end
