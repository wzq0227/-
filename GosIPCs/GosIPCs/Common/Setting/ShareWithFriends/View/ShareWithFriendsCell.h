//
//  ShareWithFriendsCell.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/27.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ShareWithFriendsModel;
@protocol ShareWithFriendsDeletDelegate <NSObject>
- (void)friendsDeleteWithCellModel:(ShareWithFriendsModel *)cellModel;
@end

NS_ASSUME_NONNULL_BEGIN

@interface ShareWithFriendsCell : UITableViewCell
/// cell模型
@property (nonatomic, strong) ShareWithFriendsModel * cellModel;
/// 代理
@property (nonatomic, weak) id<ShareWithFriendsDeletDelegate> delegate;
+ (instancetype)cellWithTableView:(UITableView *) tableView
                        cellModel:(ShareWithFriendsModel *) cellModel
                         delegate:(id<ShareWithFriendsDeletDelegate>) delegate;
@end

NS_ASSUME_NONNULL_END
