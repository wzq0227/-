//
//  TempAlarmPickModel.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/26.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TempAlarmPickModel : NSObject
/**
 具体数值
 */
@property (nonatomic, assign) double value;   // 选择值
/**
 该显示的数值
 */
@property (nonatomic, strong) NSString * ValueStr;   // 显示值

@end

NS_ASSUME_NONNULL_END
