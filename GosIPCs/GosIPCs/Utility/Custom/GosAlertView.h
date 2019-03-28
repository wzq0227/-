//  GosAlertView.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/19.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@class GosAlertAction;

/**
 @brief 自定义弹框
 @discussion 可自定义多个按钮，标题，信息
 @note 两个按钮并排；一个按钮或三个按钮及以上开始横排向下排列
 */
@interface GosAlertView : UIControl
/// 创建显示方法——默认样式
+ (GosAlertView *)alertShowWithTitle:(NSString *_Nullable)title
                             message:(NSString *_Nullable)message
                        cancelAction:(GosAlertAction *_Nullable)cancelAction
                        otherActions:(GosAlertAction *)otherActions, ...NS_REQUIRES_NIL_TERMINATION;
/// 创建显示方法——自定义富文本
+ (GosAlertView *)alertShowWithAttributeTitle:(NSAttributedString *_Nullable)attributeTitle
                             attributemessage:(NSAttributedString *_Nullable)attributeMessage
                                 cancelAction:(GosAlertAction *_Nullable)cancelAction
                                 otherActions:(GosAlertAction *)otherActions, ...NS_REQUIRES_NIL_TERMINATION;
/// 手动显示方法
- (void)show;
/// 手动消失方法
- (void)dismiss;
@end



typedef void(^__nullable AlertClickAction)(GosAlertAction *_Nullable action);
typedef NS_ENUM(NSUInteger, GosAlertActionStyle) {
    GosAlertActionStyleDefault, // 默认与Cancel一致
    GosAlertActionStyleCancel,  // 取消样式：GOS_COLOR_RGB(0x999999)，GOS_FONT(16)
    GosAlertActionStyleBlue,    // 蓝色样式：GOS_COLOR_RGB(0x55AFFC)，GOS_FONT(16)
};

/**
 自定义弹框的按钮属性
 */
@interface GosAlertAction : NSObject
/// 按钮的文字，同时由此加默认的富属性设置attributeText
@property (nonatomic, copy) NSString *text;
/// 文本样式，由此与text确定attributeText
@property (nonatomic, assign) GosAlertActionStyle style;
/// 点击响应block
@property (nonatomic, copy) AlertClickAction clickAction;

/// 按钮的富文字，使用此属性用于显示
@property (nonatomic, readonly, copy) NSAttributedString *attributeText;

+ (GosAlertAction *)actionWithText:(NSString *)text
                             style:(GosAlertActionStyle)style
                       clickAction:(AlertClickAction)clickAtion;
@end


NS_ASSUME_NONNULL_END
