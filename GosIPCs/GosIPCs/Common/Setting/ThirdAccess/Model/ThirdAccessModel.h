//  ThirdAccessModel.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/7.
//  Copyright © 2018 goscam. All rights reserved.

#import <Foundation/Foundation.h>
typedef NS_OPTIONS(unsigned int, AccessThirdPartySupport) {
    AccessThirdPartySupport_Echo = 1 << 0,
    AccessThirdPartySupport_Show = 1 << 1,
    AccessThirdPartySupport_GoogleHome = 1 << 2,
};
NS_ASSUME_NONNULL_BEGIN

@interface ThirdAccessModel : NSObject
/// imageStr
@property (nonatomic, strong) NSString * imgStr;   // logo
/// 跳转的btn
@property (nonatomic, strong) NSString * jumpBtnStr;   // btnString
/// 跳转的URL
@property (nonatomic, strong) NSURL * alexaStr;   // aelxt string url
/// 右侧小按钮跳转URL
@property (nonatomic, strong) NSURL * settingStr;   // url
@end

NS_ASSUME_NONNULL_END
