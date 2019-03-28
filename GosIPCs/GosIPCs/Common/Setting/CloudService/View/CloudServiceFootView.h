//
//  CloudServiceFootView.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FreePackageTypesApiRespModel;
typedef NS_ENUM(NSInteger, cloudServiceOrderType) {
    cloudServiceOrderType_FreeDay,      //  30天免费
    cloudServiceOrderType_Pay           //  支付
};
@protocol CloudServiceFootViewDelegate <NSObject>
- (void)CloudServiceFootViewBtnClick:(cloudServiceOrderType) payType;
@end

@interface CloudServiceFootView : UIView
@property (nonatomic, assign) cloudServiceOrderType payType;
///  免费试用按钮
@property (weak, nonatomic) IBOutlet UIButton *freeUserBtn;
/// 支付按钮
@property (weak, nonatomic) IBOutlet UIButton *payBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *payTopConstraint;  //  支付按钮距顶部
@property (nonatomic,weak) id<CloudServiceFootViewDelegate> delegate;
/// 免费试用模型
@property (nonatomic, strong) FreePackageTypesApiRespModel * freeApiRespModel;

@end
