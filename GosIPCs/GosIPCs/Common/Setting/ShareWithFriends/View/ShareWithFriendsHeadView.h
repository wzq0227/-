//  ShareWithFriendsHeadView.h
//  Goscom
//
//  Create by 匡匡 on 2018/12/20.
//  Copyright © 2018 goscam. All rights reserved.

#import <UIKit/UIKit.h>
@class ShareWithFriendsModel;

@protocol ShareFriendsHeadViewDelegate <NSObject>
@optional;
/**
 确认分享

 @param shareUserID  分享的ID
 */
- (void)shareFriendsConfirm:(NSString *) shareUserID;

/**
 编辑点击

 @param isEdit 是否编辑
 */
- (void)shareFriendsEdit:(BOOL) isEdit;
@end

NS_ASSUME_NONNULL_BEGIN

@interface ShareWithFriendsHeadView : UIView
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;     //  输入对方账号textfield
/// 代理
@property (nonatomic, weak) id<ShareFriendsHeadViewDelegate> delegate;
/// 分享数组
@property (nonatomic, strong) NSMutableArray <ShareWithFriendsModel *> * dataArr;
@end

NS_ASSUME_NONNULL_END
