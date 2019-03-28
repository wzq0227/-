//  SimilarCellButton.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/4.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 类似Cell样式的按钮
 */
IBInspectable
@interface SimilarCellButton : UIButton
/// 标题字符
@property (nonatomic, copy) NSString *titleString;

@end

NS_ASSUME_NONNULL_END
