//  MessageCenterViewModel.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/26.
//  Copyright © 2018年 goscam. All rights reserved.

#import <Foundation/Foundation.h>

@protocol MessageCenterViewModelDelegate <NSObject>

- (void)messageDidReceivedData:(id)data;

@end

NS_ASSUME_NONNULL_BEGIN

@interface MessageCenterViewModel : NSObject

@property (nonatomic, weak) id<MessageCenterViewModelDelegate> delegate;

/// 获取页面默认数据
- (NSMutableArray *)generateDefaultTableDataArray;

#pragma mark - 校验方法
/// 判断数组是否存在有效数据
- (BOOL)checkIsValidDataExistedWithDataArray:(NSMutableArray *)dataArray;
/// 判断数组是否所有数据都被选择了
- (BOOL)checkIsAllBeingSelectedWithDataArray:(NSMutableArray *)dataArray;
/// 判断数组存在数据可被删除
- (BOOL)checkIsExistDeletableWithDataArray:(NSMutableArray *)dataArray;

#pragma mark - 增删查改
/// 从删除tableview数组中删除已经选择的项
- (void)deleteWithDataArray:(NSMutableArray *)dataArray deviceID:(nullable NSString *)deviceID;
/// 从数据库中刷新数据，更新到tableview数组中
- (void)updateFromDataBaseWithDataArray:(NSMutableArray *)dataArray deviceID:(nullable NSString *)deviceID;
/// 设置数据
- (void)modifyWithDataArray:(NSMutableArray *)dataArray editing:(BOOL)editing selected:(BOOL)selected;
/// 设置数据
- (void)modifyWithDataArray:(NSMutableArray *)dataArray selected:(BOOL)selected;

#pragma mark - 数据方法


@end

NS_ASSUME_NONNULL_END
