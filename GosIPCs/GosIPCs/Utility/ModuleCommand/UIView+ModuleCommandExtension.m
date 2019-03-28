//  UIView+ModuleCommandExtension.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/28.
//  Copyright © 2018年 goscam. All rights reserved.

#import "UIView+ModuleCommandExtension.h"
#import <objc/runtime.h>

@implementation UIView (ModuleCommandExtension)
- (ModuleCommand *)moduleCommand {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setModuleCommand:(ModuleCommand *)moduleCommand {
    objc_setAssociatedObject(self, @selector(moduleCommand), moduleCommand, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
