//  GosAlertListView.h
//  GosIPCs
//
//  Create by daniel.hu on 2018/12/22.
//  Copyright © 2018年 goscam. All rights reserved.

#import <UIKit/UIKit.h>

@class GosAlertListView;
@class GosAlertListCellModel;

/**
 点击回调代理
 */
@protocol GosAlertListViewDelegate <NSObject>
- (void)gosAlertListView:(GosAlertListView *)alertView
                didClick:(GosAlertListCellModel *_Nullable)alertCellModel
                   index:(NSInteger)index;
@end
/// 点击事件回调block
typedef void(^GosAlertListViewCallBack) (NSInteger index, GosAlertListCellModel *_Nullable alertCellModel);
NS_ASSUME_NONNULL_BEGIN

/**
 @brief 自定义列表弹框
 */
@interface GosAlertListView : UIControl
@property (nonatomic, copy) GosAlertListViewCallBack callback;
@property (nonatomic, weak) id<GosAlertListViewDelegate> delegate;

+ (instancetype)alertTableShowWithTitle:(NSString *)title
                                 cancel:(NSString *_Nullable)cancel
                              dataArray:(NSArray *)dataArray
                            textKeyPath:(NSString *)keyPath
                               callback:(GosAlertListViewCallBack)callback;
+ (instancetype)alertTableShowWithTitle:(NSString *)title
                                 cancel:(NSString *_Nullable)cancel
                              dataArray:(NSArray *)dataArray
                            textKeyPath:(NSString *)keyPath
                               delegate:(id<GosAlertListViewDelegate>)delegate;
@end


@interface GosAlertListCellModel : NSObject
/// 文本，用于显示
@property (nonatomic, copy) NSString *text;
/// 附加数据，可以将转换模型直接复制给此参数
@property (nonatomic, strong) id extraData;
/**
 @brief 通用转化此模型数组的方法
 @param dataArray 其他模型数组
 @param keyPath 用于显示的参数名
 @return GosAlertListCellModel模型数组
 
 @attention 如果未能通过keyPath找到对应的参数，将返回空数组
 */
+ (NSArray <GosAlertListCellModel *> *)convertFromDataArray:(NSArray *)dataArray withTextKeyPath:(NSString *_Nullable)keyPath;
@end

@interface GosAlertListCell : UITableViewCell
/// 初始化方法
+ (instancetype)cellWithTableView:(UITableView *)tableView model:(GosAlertListCellModel *)model;
+ (CGFloat)cellHeightWithModel:(GosAlertListCellModel *_Nullable)model;
@end
NS_ASSUME_NONNULL_END
