//  UIView+ModuleCommandExtension.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/28.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>
#import "ModuleCommand.h"
NS_ASSUME_NONNULL_BEGIN

@interface UIView (ModuleCommandExtension)
@property (nonatomic, strong) ModuleCommand *moduleCommand;
@end

NS_ASSUME_NONNULL_END
