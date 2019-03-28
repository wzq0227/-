//  MessageCenterSetupCellModel.h
//  Goscom
//
//  Create by daniel.hu on 2018/12/5.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageCenterSetupCellModel : NSObject
/// 标题
@property (nonatomic, copy) NSString *titleText;
/// 开启
@property (nonatomic, assign, getter=isOn) BOOL on;
@end

NS_ASSUME_NONNULL_END
