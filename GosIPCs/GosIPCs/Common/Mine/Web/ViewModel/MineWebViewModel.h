//  MineWebViewModel.h
//  Goscom
//
//  Create by daniel.hu on 2018/11/22.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
/// 网页目标类型
typedef NS_ENUM(NSInteger, MineWebDestination) {
    MineWebDestinationUnknown,          // 未知网页
    MineWebDestinationUserAgreement,    // 用户手册
    MineWebDestinationFAQ,              // FAQ
};


@interface MineWebViewModel : NSObject

/**
 通过目标网页类型，获取网页应该显示的标题以及地址

 @param destination in 网页目标类型
 @param title out 页面标题
 @param url out 地址
 */
- (void)loadMineWebDestination:(MineWebDestination)destination title:(NSString * _Nullable *)title url:(NSURL * _Nullable *)url;

@end


/**
 网络地址
 */
@interface NSString (GosURLString)

/// 用户协议地址
+ (NSString *)userAgreementURLString;
/// FAQ地址
+ (NSString *)faqURLString;

@end
