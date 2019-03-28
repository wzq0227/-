//  ExperienceCenterCellModel.h
//  Goscom
//
//  Create by daniel.hu on 2018/11/29.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>


/// 反馈跳转目标Block
typedef UIViewController *(^ExperienceCellTurnToVCBlock)(void);

typedef NS_ENUM(NSInteger, ExperienceCenterCellType) {
    ExperienceCenterCellTypeVR360,  // 360 吊装视频
    ExperienceCenterCellTypeVR180,  // 180 侧装视频
    ExperienceCenterCellTypeNVR,    // NVR 视频
    ExperienceCenterCellTypeIPC,    // IPC 视频
};

NS_ASSUME_NONNULL_BEGIN

@interface ExperienceCenterCellModel : NSObject <NSCopying>
@property (nonatomic, assign) ExperienceCenterCellType cellType;

@property (nonatomic, readonly, copy) UIImage *icon;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *times;

@property (nonatomic, copy) ExperienceCellTurnToVCBlock cellTurnToVCBlock;

+ (instancetype)cellModelWithCellType:(ExperienceCenterCellType)cellType cellTurnToVCBlock:(ExperienceCellTurnToVCBlock)cellTurnToVCBlock;
@end

NS_ASSUME_NONNULL_END
