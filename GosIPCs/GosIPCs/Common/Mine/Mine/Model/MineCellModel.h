//  MineCellModel.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/20.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MineCellModelProtocol.h"

typedef NS_OPTIONS(NSInteger, MineCellSeparatorType) {
    MineCellSeparatorTypeNone      = 0,        // 无
    MineCellSeparatorTypeTop       = 1 << 0,   // 上分割线
    MineCellSeparatorTypeBottom    = 1 << 1,   // 下分割线
    MineCellSeparatorTypeBoth      = MineCellSeparatorTypeTop | MineCellSeparatorTypeBottom,           // 上下都有
};
typedef NS_ENUM(NSInteger, MineCellAccessoryType) {
    MineCellAccessoryTypeNone,  // 无
    MineCellAccessoryTypeArrow, // 箭头
};

NS_ASSUME_NONNULL_BEGIN

@interface MineCellModel : NSObject <MineCellModelProtocol>
/// 标记
@property (nonatomic, assign) NSInteger cellMark;
/// text
@property (nonatomic, copy) NSString *titleText;
/// 分割线类型
@property (nonatomic, assign) MineCellSeparatorType separatorType;
/// cell右边视图类型
@property (nonatomic, assign) MineCellAccessoryType accessoryType;
/// 跳转block
@property (nonatomic, copy, nullable) MineCellClickActionBlock cellClickActionBlock;

+ (instancetype)cellModelWithTitle:(NSString *)title
                   separatorType:(MineCellSeparatorType)separatorType
                    accessoryType:(MineCellAccessoryType)accessoryType
                      clickAction:(MineCellClickActionBlock _Nullable)cellAction;

+ (instancetype)cellModelWithMark:(NSInteger)mark
                            title:(NSString *)title
                   separatorType:(MineCellSeparatorType)separatorType
                    accessoryType:(MineCellAccessoryType)accessoryType
                      clickAction:(MineCellClickActionBlock _Nullable)cellAction;
@end

NS_ASSUME_NONNULL_END
