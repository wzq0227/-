//
//  LightDurationModel.h
//  Goscom
//
//  Created by 匡匡 on 2018/11/30.
//  Copyright © 2018 goscam. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, lightDurationCellType) {
    lightDurationCellType_Switch,       //  右边是switch
    lightDurationCellType_Label,        //  右边是label
};
typedef NS_ENUM(NSInteger, lightDurationEditType) {
    lightDurationEditType_Editable,       //  可点击
    lightDurationEditType_NoEdit,         //  不可点击
};


NS_ASSUME_NONNULL_BEGIN

@interface LightDurationModel : NSObject
@property (nonatomic, copy) NSString * titleStr;   // 标题名
@property (nonatomic, copy) NSString * dateTimeStr;   // 时间
@property (nonatomic, assign) BOOL isOn;   // 是否开启
@property (nonatomic, assign) lightDurationCellType cellType;   // cell的类型
@property (nonatomic, assign) lightDurationEditType editType;   // 是否可编辑
@end

NS_ASSUME_NONNULL_END
