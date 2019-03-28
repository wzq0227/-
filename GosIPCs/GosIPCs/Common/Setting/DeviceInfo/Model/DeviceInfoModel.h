//
//  DeviceInfoModel.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceInfoTypeModel : NSObject
@property (nonatomic, strong) NSString * sectionTitleStr;   // 一组的标题
@property (nonatomic, strong) NSMutableArray * sectionDataArr;   // 一组数据
@end


typedef NS_ENUM(NSInteger, DeviceInfoCellType){
    DeviceInfoCellType_hasNext,           //  有下一页
    DeviceInfoCellType_hasDetail,        //  右侧有详细数值
};

NS_ASSUME_NONNULL_BEGIN

@interface DeviceInfoModel : NSObject
@property (nonatomic, strong) NSString * titleStr;   // 左边的标题
@property (nonatomic, strong) NSString * dataStr;    // 右边的数值
@property (nonatomic, assign) BOOL hasNewVersion;   // 是否可升级
@property (nonatomic, assign) DeviceInfoCellType cellType;   // cell 的类型
@end

NS_ASSUME_NONNULL_END
