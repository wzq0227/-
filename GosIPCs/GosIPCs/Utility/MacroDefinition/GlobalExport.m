//
//  GlobalExport.m
//  GosIPCs
//
//  Created by ShenYuanLuo on 2018/12/26.
//  Copyright © 2018年 goscam. All rights reserved.
//

#import "GlobalExport.h"

@implementation GlobalExport

NSString * const kStreamServerAddrsNorthAmerica = @"35.163.36.236:6001";
NSString * const kStreamServerAddrsEuropean     = @"35.163.36.236:6001";
NSString * const kStreamServerAddrsChina        = @"119.23.128.209:6001";
NSString * const kStreamServerAddrsAsiaPacific  = @"35.163.36.236:6001";
NSString * const kStreamServerAddrsMiddleEast   = @"35.163.36.236:6001";

NSString * const kAutoLoginSuccessNotify        = @"AutoLoginSuccessNotify";
NSString * const kLoginSuccessNotify            = @"LoginSuccessNotify";
NSString * const kLogoutSuccessNotify           = @"LogoutSuccessNotify";

NSString * const kCurPreviewDevStatusNotify     = @"CurPreviewDevStatusNotify";
NSString * const kCurDevConnectingNotify        = @"CurDevConnectingNotify";
NSString * const kReDisConnAndConnAgainNotify   = @"ReDisConnAndConnAgainNotify";

NSString * const kPushMsgSaveSuccessNotify      = @"PushMsgSaveSuccessNotify";
NSString * const kClickPushMsgToUpdateListNotify= @"ClickPushMsgToUpdateListNotify";
NSString * const kCheckedPushStatusNotify       = @"CheckedPushStatusNotify";
NSString * const kClickPushMsgNotify            = @"ClickPushMsgNotify";
NSString * const kIsVideoShowingNotify          = @"IsVideoPlayShowingNotify";

NSString * const kPushMsgHasReadedNotify        = @"PushMsgHasReadedNotify";

NSString * const kStartDownloadTFPhotoNotify    = @"StartDownloadTFPhotoNotify";

NSUInteger kMeasureSizeGB = 1073741824;
NSUInteger kMeasureSizeMB = 1048576;
NSUInteger kMeasureSizeKB = 1024;

NSString * const kDownloadTFPhotoRowKey         = @"DownloadTFPhotoRow";
NSString * const kTFMediaKey                    = @"TFMedia";
NSString * const kRowIndexKey                   = @"RowIndex";

NSString * const kHistoryAccountList            = @"HistoryAccountList";

NSString * const kCurNetworkChangeNotify        = @"CurrentNetworkChangeNotify";

NSString * const kSaveCoverNotify               = @"SaveCoverNotify";
NSString * const kModifyDevInfoNotify           = @"ModifyDevInfoNotify";
NSString * const kDeleteDeviceNotify            = @"DeleteDeviceNotify";
/// 扫描二维码提示框 (添加设备)不再提醒
NSString * const kNoRemindAddNotify             = @"kNoRemindAddNotify";
//// 扫描二维码提示框 (WiFi设置)不再提醒
NSString * const kNoRemindWiFiNotify            = @"kNoRemindWiFiNotify";

@end
