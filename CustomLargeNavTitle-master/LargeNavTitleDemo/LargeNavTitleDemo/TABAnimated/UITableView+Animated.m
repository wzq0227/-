//
//  UITableView+Animated.m
//  AnimatedDemo
//
//  Created by tigerAndBull on 2018/9/14.
//  Copyright © 2018年 tigerAndBull. All rights reserved.
//

#import "UITableView+Animated.h"

#import <objc/runtime.h>

#import "TABViewAnimated.h"

@implementation UITableView (Animated)

+ (void)load {
    
    // Ensure that the exchange method executed only once.
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        // Gets the viewDidLoad method to the class,whose type is a pointer to a objc_method structure.
        Method originMethod = class_getInstanceMethod([self class], @selector(setDataSource:));
        
        // Get the method you created.
        Method newMethod = class_getInstanceMethod([self class], @selector(tab_setDataSource:));
        
        IMP newIMP = method_getImplementation(newMethod);
        
        BOOL isAdd = class_addMethod([self class], @selector(tab_setDataSource:), newIMP, method_getTypeEncoding(newMethod));
        
        if (isAdd) {
            
            // replace
            class_replaceMethod([self class], @selector(setDataSource:), newIMP, method_getTypeEncoding(newMethod));
        }else {
            
            // exchange
            method_exchangeImplementations(originMethod, newMethod);
        }
        
    });
}

- (void)tab_setDataSource:(id<UITableViewDataSource>)dataSource {
    
    SEL oldSelector = @selector(tableView:numberOfRowsInSection:);
    SEL newSelector = @selector(tab_tableView:numberOfRowsInSection:);
    
    if ([self.delegate respondsToSelector:oldSelector]) {
        [self exchangeTableDelegateMethod:oldSelector withNewSel:newSelector withTableDelegate:dataSource];
    }
    
    [self tab_setDataSource:dataSource];
}

#pragma mark - TABTableViewDataSource

- (NSInteger)tab_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // If the animation running, return animatedCount.
    if (tableView.animatedStyle == TABTableViewAnimationStart) {
        return tableView.animatedCount;
    }
    return [self tab_tableView:tableView numberOfRowsInSection:section];
}

#pragma mark - Private Methods


/**
 exchange method
 
 @param oldSelector old method's sel
 @param newSelector new method's sel
 @param delegate return nil
 */
- (void)exchangeTableDelegateMethod:(SEL)oldSelector
                         withNewSel:(SEL)newSelector
                  withTableDelegate:(id<UITableViewDataSource>)delegate {
    
    Method oldMethod_del = class_getInstanceMethod([delegate class], oldSelector);
    Method oldMethod_self = class_getInstanceMethod([self class], oldSelector);
    Method newMethod = class_getInstanceMethod([self class], newSelector);
    
    if ([self isKindOfClass:[delegate class]]) {
        method_exchangeImplementations(oldMethod_del, newMethod);
    } else {
        
        BOOL isSuccess = class_addMethod([delegate class], oldSelector, class_getMethodImplementation([self class], newSelector), method_getTypeEncoding(newMethod));
        
        if (isSuccess) {
            
            class_replaceMethod([delegate class], newSelector, class_getMethodImplementation([self class], oldSelector), method_getTypeEncoding(oldMethod_self));
        } else {
            
            BOOL isVictory = class_addMethod([delegate class], newSelector, class_getMethodImplementation([delegate class], oldSelector), method_getTypeEncoding(oldMethod_del));
            if (isVictory) {
                class_replaceMethod([delegate class], oldSelector, class_getMethodImplementation([self class], newSelector), method_getTypeEncoding(newMethod));
            }
        }
    }
}

#pragma mark - Getter / Setter

- (TABTableViewAnimationStyle)animatedStyle {
    
    NSNumber *value = objc_getAssociatedObject(self, @selector(animatedStyle));
    
    // If the animation is running, disable touch events.
    if (value.intValue == 1) {
        self.scrollEnabled = NO;
        self.allowsSelection = NO;
    }else {
        self.scrollEnabled = YES;
        self.allowsSelection = YES;
    }
    return value.intValue;
}

- (void)setAnimatedStyle:(TABTableViewAnimationStyle)animatedStyle {
    objc_setAssociatedObject(self, @selector(animatedStyle), @(animatedStyle), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)animatedCount {
    NSNumber *value = objc_getAssociatedObject(self, @selector(animatedCount));
    return (value.integerValue == 0)?(3):(value.integerValue);
}

- (void)setAnimatedCount:(NSInteger)animatedCount {
    objc_setAssociatedObject(self, @selector(animatedCount), @(animatedCount), OBJC_ASSOCIATION_ASSIGN);
}

@end
