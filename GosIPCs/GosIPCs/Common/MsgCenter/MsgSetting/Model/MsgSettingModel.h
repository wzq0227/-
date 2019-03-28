//
//  MsgSettingModel.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/18.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSConfigSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface MsgSettingModel : NSObject
@property (nonatomic, readwrite, strong) DevDataModel *devModel;
/** 推送状态标识；YES：打开，NO：关闭 */
@property (nonatomic, readwrite, assign) BOOL PushFlag;

@end

NS_ASSUME_NONNULL_END
