//  MineViewModelDelegate.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/21.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Mine类下的ViewModel共有方法代理
 */
@protocol MineViewModelDelegate <NSObject>
/// 生产tableDataArray
- (NSArray *)generateTableDataArray;
@end

NS_ASSUME_NONNULL_END
