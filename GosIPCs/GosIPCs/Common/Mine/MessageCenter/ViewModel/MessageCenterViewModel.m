//  MessageCenterViewModel.m
//  GosIPCs
//
//  Create by daniel.hu on 2018/11/26.
//  Copyright © 2018年 goscam. All rights reserved.

#import "MessageCenterViewModel.h"
#import "MessageCenterCellModel.h"
#import "MessageCenterSetupViewController.h"
// 有新推送通知 key
#define NEW_APNS_NOTIFY @"newPushMsgtNotify"

@implementation MessageCenterViewModel
//- (instancetype)init {
//    if (self = [super init]) {
//        // 新消息推送
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDidReceived:) name:NEW_APNS_NOTIFY object:nil];
//    }
//    return self;
//}
//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
- (void)messageDidReceived:(NSNotification *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(messageDidReceivedData:)]) {
        [_delegate messageDidReceivedData:sender.object];
    }
    
}
- (NSMutableArray *)generateDefaultTableDataArray {
    return [NSMutableArray arrayWithArray:@[
             @[
                 // 设置
                 [MessageCenterCellModel modelWithTitleText:@"MessageCenterSetup" separatorType:MessageCellSeparatorTypeNone cellStyle:MessageCellStyleArrow cellAction:^UIViewController *(id hook) {
                    return [[MessageCenterSetupViewController alloc] init];
                    }],
                 ],
             // 后面可变
             [NSMutableArray array],
             ]];
}




#pragma mark - 校验方法
/// 判断数组是否存在有效数据
- (BOOL)checkIsValidDataExistedWithDataArray:(NSMutableArray *)dataArray {
    // 只要存在可编辑项，就是存在有效数据
    for (NSArray *subArray in dataArray) {
        for (MessageCenterCellModel *cellModel in subArray) {
            if (cellModel.isEditable) {
                return YES;
            }
        }
    }
    return NO;
}
/// 判断数组是否所有数据都被选择了
- (BOOL)checkIsAllBeingSelectedWithDataArray:(NSMutableArray *)dataArray {
    // 存在的可编辑项数据未被选择就返回NO
    for (NSArray *subArray in dataArray) {
        for (MessageCenterCellModel *cellModel in subArray) {
            if (cellModel.isEditable && !cellModel.isSelected) {
                return NO;
            }
        }
    }
    return YES;
}
/// 判断数组存在数据可被删除
- (BOOL)checkIsExistDeletableWithDataArray:(NSMutableArray *)dataArray {
    // 只要存在可编辑项，并且数据被选择了就可被删除
    for (NSArray *subArray in dataArray) {
        for (MessageCenterCellModel *cellModel in subArray) {
            if (cellModel.isEditable && cellModel.isSelected) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - 增删查改
/// 从删除tableview数组中删除已经选择的项
- (void)deleteWithDataArray:(NSMutableArray *)dataArray deviceID:(nullable NSString *)deviceID {
    // 查找已经选择的
    NSMutableArray *tempNeedDelete = [NSMutableArray array];
    for (NSMutableArray *subArray in dataArray) {
        for (MessageCenterCellModel *cellModel in subArray) {
            if (cellModel.isEditable && cellModel.isSelected) {
                
                [tempNeedDelete addObject:cellModel];
            }
        }
    }
    // 从数据库中删除已选项
    [self removeDataBaseWithCellModel:tempNeedDelete deviceID:deviceID];
    // 从数组中删除
    for (NSMutableArray *subArray in dataArray) {
        if ([subArray isKindOfClass:[NSMutableArray class]]) {
            [subArray removeObjectsInArray:tempNeedDelete];
        }
    }
}
/// 从数据库中刷新数据，更新到tableview数组中
- (void)updateFromDataBaseWithDataArray:(NSMutableArray *)dataArray deviceID:(nullable NSString *)deviceID {
    // 从数据库中获取数据
    NSArray *dataBaseArray = [self readDataBaseArrayWithDeviceID:deviceID];
    // FIXME: 如果为空 跳出
//    if ([dataBaseArray count] == 0) return ;
    // 转化之后添加到dataArray中
    for (id subItem in dataArray) {
        if ([subItem isKindOfClass:[NSMutableArray class]]) {
            
            [subItem addObjectsFromArray:[self convertDataBaseArrayToCellModelArray:dataBaseArray]];
            // FIXME: 记得删除假数据
            [subItem addObject:[self modelWithTitle:@"客厅"]];
            [subItem addObject:[self modelWithTitle:@"卧室"]];
        }
    }
}
- (void)modifyWithDataArray:(NSMutableArray *)dataArray editing:(BOOL)editing selected:(BOOL)selected {
    for (NSArray *subArray in dataArray) {
        for (MessageCenterCellModel *cellModel in subArray) {
            if (cellModel.isEditable) {
                cellModel.editing = editing;
                cellModel.selected = selected;
            }
        }
    }
}
- (void)modifyWithDataArray:(NSMutableArray *)dataArray selected:(BOOL)selected {
    for (NSArray *subArray in dataArray) {
        for (MessageCenterCellModel *cellModel in subArray) {
            if (cellModel.isEditable) {
                cellModel.selected = selected;
            }
        }
    }
}



#pragma mark - data base method
/// 数据模型 转化为 MessageCenterCellModel
- (MessageCenterCellModel *)convertDataBaseModelToCellModel:(id)dataBaseModel {
    // TODO: 完善消息模型转化方法
    return nil;
}
/// 数据模型数组 转化为 NSArray <MessageCenterCellModel*> *
- (NSArray <MessageCenterCellModel *> *)convertDataBaseArrayToCellModelArray:(NSArray *)dataBaseArray {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:dataBaseArray.count];
    for (id dataBase in dataBaseArray) {
        // !!!: 注意第一个的cell顶线是没有的
        [result addObject:[self convertDataBaseModelToCellModel:dataBase]];
    }
    return [result copy];
}
/// 根据deviceId读取数据库中的数据
- (NSArray *)readDataBaseArrayWithDeviceID:(nullable NSString *)deviceID {
    // TODO: 完善读取数据库的推送消息
    if (deviceID) {
        // 读取专属消息
    } else {
        // 读取全部消息
    }
    return [NSArray array];
}
/// 写数据到数据库中
- (void)writeDataBaseArray:(NSArray *)dataBaseArray deviceID:(nullable NSString *)deviceID {
    // TODO: 完善保存推送消息到数据库
}
/// 从数据库中删除cellModel数组
- (void)removeDataBaseWithCellModel:(NSArray *)cellModelArray deviceID:(nullable NSString *)deviceID {
    if ([cellModelArray count] == 0) return ;
    NSMutableArray *temp = [[self readDataBaseArrayWithDeviceID:deviceID] mutableCopy];
    if ([temp count] == 0) return ;
    for (id dataBase in temp) {
        for (MessageCenterCellModel *cellModel in cellModelArray) {
            if ([self compareCellModel:cellModel isEqualToDataBase:dataBase]) {
                [temp removeObject:dataBase];
            }
        }
    }
}
/// 比较数据模型与MessageCenterCellModel是否一致的方法
- (BOOL)compareCellModel:(MessageCenterCellModel *)cellModel isEqualToDataBase:(id)dataBase {
    return NO;
}
- (MessageCenterCellModel *)modelWithTitle:(nonnull NSString *)title {
    return [MessageCenterCellModel modelWithTitleText:title
                                        detailText:@"2018-12-25 18:12:06"
                                     separatorType:MessageCellSeparatorTypeBottom
                                         cellStyle:MessageCellStyleDetail
                                          editable:YES
                                        cellAction:nil];
}
@end
