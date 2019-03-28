//
//  UIView+GosCoord.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/15.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (GosCoord)

/** x坐标 */
@property (nonatomic,assign) CGFloat x;
/** y坐标 */
@property (nonatomic,assign) CGFloat y;
/** 宽度 */
@property (nonatomic,assign) CGFloat width;
/** 高度 */
@property (nonatomic,assign) CGFloat height;
/** 大小 */
@property (nonatomic,assign) CGSize  size;
/** 位置 */
@property (nonatomic,assign) CGPoint origin;
/** x中心 */
@property (nonatomic,assign) CGFloat centerX;
/** y中心 */
@property (nonatomic,assign) CGFloat centerY;

@end

NS_ASSUME_NONNULL_END
