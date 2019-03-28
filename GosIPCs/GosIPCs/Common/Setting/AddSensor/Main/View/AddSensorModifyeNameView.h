//
//  AddSensorModifyeNameView.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol modifyNameDelegate <NSObject>

-(void) modifyNameWithNewName:(NSString *) name;

@end
@interface AddSensorModifyeNameView : UIView
/// 标题 共用
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
/// 代理
@property (nonatomic, weak) id<modifyNameDelegate> delegate;
/// 占位文字
@property (nonatomic, strong) NSString * placeTitle;

@end

NS_ASSUME_NONNULL_END
