//  CloudDownloadFileApiManager.h
//  GosIPCs
//
//  Create by daniel.hu on 2019/1/3.
//  Copyright © 2019年 goscam. All rights reserved.

#import "GosApiBaseManager.h"

NS_ASSUME_NONNULL_BEGIN
@class TokenCheckApiRespModel;
@class VideoSlicesApiRespModel;

/**
 下载文件
 */
@interface CloudDownloadFileApiManager : GosApiBaseManager <GosApiManager>

/**
 请求
 默认downloadProcess 打印进度
 */
- (NSInteger)loadDataWithTokenModel:(TokenCheckApiRespModel *)tokenModel
                         videoModel:(VideoSlicesApiRespModel *)videoModel
               destionationFilePath:(NSURL *)destionationFilePath;

/// 请求
- (NSInteger)loadDataWithTokenModel:(TokenCheckApiRespModel *)tokenModel
                         videoModel:(VideoSlicesApiRespModel *)videoModel
                    downloadProcess:(nullable void (^) (NSProgress * _Nonnull process))downloadProcess
                        destination:(nullable NSURL * _Nonnull (^)(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response))desination;
@end

NS_ASSUME_NONNULL_END
