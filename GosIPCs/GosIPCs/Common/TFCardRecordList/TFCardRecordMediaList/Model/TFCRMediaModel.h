//
//  TFCRMediaModel.h
//  Goscom
//
//  Created by shenyuanluo on 2019/1/2.
//  Copyright © 2019 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSConfigSDKDefine.h"
#import "iOSConfigSDKModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 设备 TF 卡录制媒体文件模型类
 注意：已重写 ‘isEqual’ 方法，在此认为-如果两个 设备 ’tfmFile‘ 相同，则两个媒体文件数据【相等】
 */
@interface TFCRMediaModel : NSObject <
                                        NSCoding,
                                        NSCopying,
                                        NSMutableCopying
                                     >
/** TF 卡媒体文件 */
@property (nonatomic, readwrite, strong) TFMediaFileModel *tfmFile;
/** 媒体文件目录 */
@property (nonatomic, readwrite, copy) NSString *mediaFilePath;
/** 媒体文件大小 */
@property (nonatomic, readwrite, copy) NSString *mediaFileSize;
/** 媒体文件是否下载 */
@property (nonatomic, readwrite, assign) BOOL hasDownload;
/** 媒体文件是否正在下载中 */
@property (nonatomic, readwrite, assign) BOOL isDownloading;
/** 媒体是否被选中 */
@property (nonatomic, readwrite, assign) BOOL hasSelect;

@end

NS_ASSUME_NONNULL_END
