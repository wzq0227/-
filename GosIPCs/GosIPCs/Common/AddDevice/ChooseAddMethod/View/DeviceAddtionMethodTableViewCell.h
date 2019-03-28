//
//  DeviceAddtionMethodTableViewCell.h
//  ULife3.5
//
//  Created by 罗乐 on 2018/9/13.
//  Copyright © 2018年 GosCam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSSmartDefine.h"

@interface DeviceAddtionMethodTableViewCell : UITableViewCell
@property (nonatomic, assign) BOOL isNeedResetFrame;
@property (nonatomic, assign) BOOL isArrowHidden;
@property (nonatomic, assign) SupportAddStyle addType;
@end
