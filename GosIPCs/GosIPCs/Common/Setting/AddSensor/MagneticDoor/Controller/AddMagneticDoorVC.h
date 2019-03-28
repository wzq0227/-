//
//  AddMagneticDoorVC.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADDIotProtocol.h"
@class DevDataModel;

NS_ASSUME_NONNULL_BEGIN

/**
 门磁界面
 */
@interface AddMagneticDoorVC : UIViewController
@property (nonatomic, strong) DevDataModel * dataModel;
/// 代理
@property (nonatomic, weak) id<ADDIotProtocolDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
