//
//  UIDevice+GosDevCheck.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/11/14.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 获取设备类型信息类
 */
typedef NS_ENUM(NSInteger, DeviceType) {
    Device_Unrecognized     = -1,
    Device_Simulator,
    Device_iPhone4,
    Device_iPhone4S,
    Device_iPhone5,
    Device_iPhone5C,
    Device_iPhone5S,
    Device_iPhone6,
    Device_iPhone6plus,
    Device_iPhone6S,
    Device_iPhone6Splus,
    Device_iPhoneSE,
    Device_iPhone7,
    Device_iPhone7plus,
    Device_iPhone8,
    Device_iPhone8plus,
    Device_iPhoneX,
    Device_iPhoneXR,
    Device_iPhoneXS,
    Device_iPhoneXSMax,
    Device_iPad1,
    Device_iPad2,
    Device_iPad3,
    Device_iPad4,
    Device_iPad5,
    Device_iPadAir1,
    Device_iPadAir2,
    Device_iPadMini1,
    Device_iPadMini2,
    Device_iPadMini3,
    Device_iPadMini4,
    Device_iPadPro1,
    Device_iPadPro2,
    Device_iPod1,
    Device_iPod2,
    Device_iPod3,
    Device_iPod4,
    Device_iPod5,
    Device_iPod6,
};

typedef NS_ENUM(NSInteger, ScreenType) {
    Screen_Unknow           = -1,
    Screen_iPhone_3_5_inch,         // iPhone 3.5 英寸屏幕
    Screen_iPhone_4_0_inch,         // iPhone 4.0 英寸屏幕
    Screen_iPhone_4_7_inch,         // iPhone 4.7 英寸屏幕
    Screen_iPhone_5_5_inch,         // iPhone 5.5 英寸屏幕
    Screen_iPhone_5_8_inch,         // iPhone 5.8 英寸屏幕
    Screen_iPhone_6_1_inch,         // iPhone 6.1 英寸屏幕
    Screen_iPhone_6_5_inch,         // iPhone 6.5 英寸屏幕
};

@interface UIDevice (GosDevCheck)

/**
 获取当前设备的类型：iPhone 4s、iPhone 5s、iPhone 6s、iPhone 6s plus...
 
 @return 具体的设备类型, 详见‘DeviceType’
 */
- (DeviceType)deviceType;



/**
 获取屏幕尺寸大小
 
 @return 屏幕大小，详见‘ScreenType’
 */
- (ScreenType)screenType;

@end

NS_ASSUME_NONNULL_END
