//  BabyMusicViewModel.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/5.
//  Copyright © 2018 goscam. All rights reserved.

#import <Foundation/Foundation.h>
#import "iOSConfigSDKDefine.h"
@class AbilityModel;
@class BabyMusicModel;
NS_ASSUME_NONNULL_BEGIN

@interface BabyMusicViewModel : NSObject

/**
 初始化TableArr
 
 @param abilityModel 能力集
 @return tableArr数组
 */
+ (NSArray *)initDataWithAbility:(AbilityModel *) abilityModel;


/**
 返回选中摇篮曲的状态(获取数据后)
 
 @param tableArr tableArr
 @param lullabyNumber 摇篮曲序号
 @return 处理后的tableArr
 */
+ (NSArray *)modifySelectData:(NSArray *) tableArr
                lullabyNumber:(LullabyNumber) lullabyNumber;



/**
 tableview点击切换歌曲
 
 @param tableArr tableArr数组
 @param index 选中了哪一行
 @param lullabyNumber 摇篮曲序号
 */
+ (void)modifyChangeBabyMusic:(NSArray *) tableArr
                     withIndex:(NSInteger) index
                 lullabyNumber:(LullabyNumber) lullabyNumber;

@end

NS_ASSUME_NONNULL_END
