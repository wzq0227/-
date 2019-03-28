//
//  NSNull+GosSafe.m
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/14.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import "NSNull+GosSafe.h"
#import <objc/runtime.h>

@implementation NSNull (GosSafe)

#define JsonObjects     @[@"", @0, @{}, @[]]
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    for (id jsonObj in JsonObjects)
    {
        if ([jsonObj respondsToSelector:aSelector])
        {
#if DEBUG
            GosLog(@"NULL出现啦！这个对象应该是是_%@",[jsonObj class]);
#endif
            return jsonObj;
        }
    }
    return [super forwardingTargetForSelector:aSelector];
}

@end
