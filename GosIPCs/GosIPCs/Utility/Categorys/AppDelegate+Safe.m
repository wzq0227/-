//
//  AppDelegate+Safe.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/14.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import "AppDelegate+Safe.h"
#import <objc/runtime.h>

@implementation AppDelegate (Safe)

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    if (sel == @selector(setupLauchGuidePages))
    {
        GosLog(@"AppDelegate has not yet implemented this method : %@", NSStringFromSelector(sel));
    }
    
    

    SEL aSel = NSSelectorFromString(@"noObjMethod");
    Method aMethod = class_getInstanceMethod(self, aSel);
    class_addMethod(self, sel, method_getImplementation(aMethod), "v@:");
    return YES;
}

- (void)noObjMethod
{
    NSLog(@"未实现这个实例方法");
}

@end
