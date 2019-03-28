//
//  MediaFileModel.h
//  MediaManager
//
//  Created by shenyuanluo on 2018/12/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MediaFileModel : NSObject <
                                        NSCopying,
                                        NSMutableCopying,
                                        NSCoding
                                     >
/** 文件创建时间（格式：yyyy-MM-dd HH:mm:ss ） */
@property (nonatomic, copy) NSString *createTime;
/** 媒体文件名称 */
@property (nonatomic, copy) NSString *fileName;
/** 视频文件大小 */
@property (nonatomic, assign) unsigned long long fileSize;
/** 媒体文件路径 */
@property (nonatomic, copy) NSString *filePath;
/** 是否被选择（用于删除时） */
@property (nonatomic, assign, getter=isSelected) BOOL selected;

@end

NS_ASSUME_NONNULL_END
