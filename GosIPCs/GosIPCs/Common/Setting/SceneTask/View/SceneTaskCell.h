//  SceneTaskCell.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/27.
//  Copyright © 2018 goscam. All rights reserved.

#import <UIKit/UIKit.h>
@class IotSceneTask;
@protocol sceneTaskCellDelegate <NSObject>

-(void) didModifySceneTask:(IotSceneTask *) taskModel;

@end
NS_ASSUME_NONNULL_BEGIN

@interface SceneTaskCell : UITableViewCell
/// 模型数据
@property (nonatomic, strong) IotSceneTask * cellModel;
/// 代理
@property (nonatomic, weak) id<sceneTaskCellDelegate> delegate;
+ (instancetype) cellWithTableView:(UITableView *) tableView
                         cellModel:(IotSceneTask *) cellModel
                          delegate:(id<sceneTaskCellDelegate>) delegate;
@end

NS_ASSUME_NONNULL_END
