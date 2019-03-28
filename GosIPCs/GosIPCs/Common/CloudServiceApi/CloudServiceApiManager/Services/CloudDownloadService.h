//  CloudDownloadService.h
//  GosIPCs
//
//  Create by daniel.hu on 2019/1/3.
//  Copyright © 2019年 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "GosServiceProtocol.h"
NS_ASSUME_NONNULL_BEGIN

/**
 构造下载请求
 请求URL为ApiManager里的methodName与params拼接结果
 */
@interface CloudDownloadService : NSObject <GosServiceProtocol>

@end

NS_ASSUME_NONNULL_END
