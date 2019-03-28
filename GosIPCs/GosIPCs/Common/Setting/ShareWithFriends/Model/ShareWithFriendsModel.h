//  ShareWithFriendsModel.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/6.
//  Copyright © 2018 goscam. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShareWithFriendsModel : NSObject
/// 分享的ID名
@property (nonatomic, strong) NSString * IDStr;   // id名
/// 是否编辑状态
@property (nonatomic, assign) BOOL isEdit;
@end

NS_ASSUME_NONNULL_END
