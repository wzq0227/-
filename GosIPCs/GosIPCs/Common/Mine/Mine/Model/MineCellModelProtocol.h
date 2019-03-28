//  MineCellModelProtocol.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/20.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 点击cell响应
typedef id (^MineCellClickActionBlock)(id _Nullable hook);

/**
 MineCellModel协议
 */
@protocol MineCellModelProtocol <NSObject>
@optional
/// 标记
@property (nonatomic, assign) NSInteger cellMark;
/// 跳转block
@property (nonatomic, copy, nullable) MineCellClickActionBlock cellClickActionBlock;

@end

NS_ASSUME_NONNULL_END
