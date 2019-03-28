//
//  PushImageManager.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/21.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PushMessage.h"

/* 推送消息图片下载结果通知
    成功：@{@"DeviceId" : @"**", @"PushImgName" : @"20181222203505*******.jpg", @"DownloadResult" : @(YES)}
    失败：@{@"DeviceId" : @"**", @"PushImgName" : @"20181222203505*******.jpg", @"DownloadResult" : @(NO)}
 */
#define PUSH_IMG_DOWNLOAD_RESULT_NOTIFY    @"PushMsgImgDownloadResult"

NS_ASSUME_NONNULL_BEGIN

@interface PushImageManager : NSObject

/*
 下载推送消息图片
 
 @param pushMsg 推送消息模型，参见‘PushMessage’
 */
+ (void)downloadImageWithMsg:(PushMessage *)pushMsg;

/*
 删除推送消息图片
 
 @param pushMsg 推送消息模型，参见‘PushMessage’
 */
+ (void)rmvPushImgOfMsg:(PushMessage *)pushMsg;

/*
 获取推送消息图片
 
 @return 推送消息图片
 */
+ (UIImage *)imgOfPushMsg:(PushMessage *)pushMsg
                    exist:(BOOL *)isExist;

/*
 推送消息图片是否正在下载中
 
 @return 是否正在下载中；YES：是，NO：否
 */
+ (BOOL)isDownloadingOfMsg:(PushMessage *)pushMsg;

@end

NS_ASSUME_NONNULL_END
