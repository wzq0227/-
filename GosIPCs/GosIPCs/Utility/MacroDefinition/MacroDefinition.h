//
//  MacroDefinition.h
//  Goscom
//
//  Created by shenyuanluo on 2018/11/10.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#ifndef MacroDefinition_h
#define MacroDefinition_h

#import "GosLoggedInUserInfo.h"
#import "GlobalExport.h"

// 打印调试
#if DEBUG
/* 输出方法名、行号 日志打印 */
#define GosLineLog(fmt, ...)    NSLog((@"%s [Line %d]: " fmt),__PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
/* 普通打印打印 */
#define GosLog(fmt, ...)        NSLog((fmt), ##__VA_ARGS__);
/* 快速更新打印 */
#define GosPrintf(fmt, ...)  {fflush(stdout);                                                           \
                              printf((fmt), ##__VA_ARGS__);}
#else
#define GosLineLog(fmt, ...)
#define GosLog(fmt, ...)
#define GosPrintf(fmt, ...)
#endif


// RGB 颜色（16进制:0xFFFFFF）
#define GOS_COLOR_RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// RGB 颜色（16进制:0xFFFFFF）
#define GOS_COLOR_RGB_A(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

// RGB颜色
#define GOS_COLOR_RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

// 透明
#define GOS_CLEAR_COLOR         [UIColor clearColor]
// 白色
#define GOS_WHITE_COLOR         [UIColor whiteColor]
// 灰色
#define GOS_GRAY_COLOR          [UIColor grayColor]
// 深灰色
#define GOS_DARK_GRAY_COLOR     [UIColor darkGrayColor]


// GOSCOM 主题颜色（渐变起始颜色）
#define GOSCOM_THEME_START_COLOR    GOS_COLOR_RGB(0x68A5FE)
// GOSCOM 主题颜色（渐变结束颜色）
#define GOSCOM_THEME_END_COLOR      GOS_COLOR_RGB(0x51B1FB)
// GosBell 主题颜色
#define GOSBELL_THEME_COLOR   GOS_COLOR_RGB(0x34317B)

// ViewController 背景颜色
#define GOS_VC_BG_COLOR     GOS_COLOR_RGB(0xF7F7F7)

// 按钮‘不可用’颜色（渐变起始颜色）0x53B0FB
#define BTN_DISABLE_START_COLOR     GOS_COLOR_RGB(0x53B0FB)
// 按钮‘不可用’颜色（渐变结束颜色）0x66A6FE
#define BTN_DISABLE_END_COLOR       GOS_COLOR_RGB(0x66A6FE)
// 按钮‘普通’颜色（渐变起始颜色）0x53B0FB
#define BTN_NORMAL_START_COLOR      GOS_COLOR_RGB(0x53B0FB)
// 按钮‘普通’颜色（渐变结束颜色）0x66A6FE
#define BTN_NORMAL_END_COLOR        GOS_COLOR_RGB(0x66A6FE)
// 按钮‘高亮’颜色（渐变起始颜色）0x2098FA
#define BTN_HIGHLIGHT_START_COLOR   GOS_COLOR_RGB(0x2098FA)
// 按钮‘高亮’颜色（渐变结束颜色）0x3287FC
#define BTN_HIGHLIGHT_END_COLOR     GOS_COLOR_RGB(0x3287FC)


// 屏幕宽度
#define GOS_SCREEN_W    [UIScreen mainScreen].bounds.size.width
// 屏幕高度
#define GOS_SCREEN_H    [UIScreen mainScreen].bounds.size.height

// 判断字符串是否为空
#define IS_EMPTY_STRING(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO)

// 获取系统字体
#define GOS_FONT(value) [UIFont systemFontOfSize:value]
// 获取系统加粗字体
#define GOS_BOLD_FONT(value)    [UIFont boldSystemFontOfSize:value]
// 获取 UIImage
#define GOS_IMAGE(str)  [UIImage imageNamed:str]

// 账号最少字符个数
#define GOS_ACCOUNT_MIN_LEN     8
// 账号最多字符个数
#define GOS_ACCOUNT_MAX_LEN     64
// 密码最少字符个数
#define GOS_PASSWORD_MIN_LEN    8
// 密码最多字符个数
#define GOS_PASSWORD_MAX_LEN    64

// 验证码最少字符个数
#define GOS_AUTH_CODE_MIN_LEN   6

// 获取验证码间隔时长（单位：秒）
#define REQ_AUTH_CODE_INTERVAL 59

#define GOS_DEFAULT_STREAM_PWD      @"goscam123"    // 设备默认取流密码


// 强、弱引用 self
#define GOS_WEAK_SELF     __weak typeof(self) weakSelf = self;
#define GOS_STRONG_SELF   __strong typeof(weakSelf) strongSelf = weakSelf; if(!strongSelf) return;

// NSCoding：编码
#define GOS_RUNTIME_ENCODE(aCoder)      unsigned int pCount;                                                                \
                                                                                                                            \
                                        objc_property_t *properties = class_copyPropertyList([self class], &pCount);        \
                                        if (properties)                                                                     \
                                        {                                                                                   \
                                            for (int i = 0; i < pCount; i++)                                                \
                                            {                                                                               \
                                                NSString *pName = @(property_getName(properties[i]));                       \
                                                [aCoder encodeObject:[self valueForKey:pName]                               \
                                                              forKey:pName];                                                \
                                            }                                                                               \
                                            free(properties);                                                               \
                                        }

// NSCoding：解码
#define GOS_RUNTIME_DECODE(aDecoder)    unsigned int pCount;                                                                \
                                        objc_property_t *properties = class_copyPropertyList([self class], &pCount);        \
                                        if (properties)                                                                     \
                                        {                                                                                   \
                                            for (int i = 0; i < pCount; i++)                                                \
                                            {                                                                               \
                                                NSString *pName = @(property_getName(properties[i]));                       \
                                                [self setValue:[aDecoder decodeObjectForKey:pName]                          \
                                                        forKey:pName];                                                      \
                                            }                                                                               \
                                            free(properties);                                                               \
                                        }

// NSCopying
#define GOS_RUNTIME_COPY(copyObj)       unsigned int pCount;                                                                \
                                        objc_property_t* properties = class_copyPropertyList([self class], &pCount);        \
                                        if (properties)                                                                     \
                                        {                                                                                   \
                                            NSMutableArray* pArray      = [NSMutableArray arrayWithCapacity:pCount];        \
                                            for (int i = 0; i < pCount ; i++)                                               \
                                            {                                                                               \
                                                [pArray addObject:@(property_getName(properties[i]))];                      \
                                            }                                                                               \
                                            free(properties);                                                               \
                                            for (int j = 0; j < pCount ; j++)                                               \
                                            {                                                                               \
                                                NSString *pName = [pArray objectAtIndex:j];                                 \
                                                id value = [self valueForKey:pName];                                        \
                                                if([value respondsToSelector:@selector(copyWithZone:)])                     \
                                                {                                                                           \
                                                    [copyObj setValue:[value copy] forKey:pName];                           \
                                                }                                                                           \
                                                else                                                                        \
                                                {                                                                           \
                                                    [copyObj setValue:value forKey:pName];                                  \
                                                }                                                                           \
                                            }                                                                               \
                                            [pArray removeAllObjects];                                                      \
                                        }

// NSMutableCopying
#define GOS_RUNTIME_MUCOPY(muCopyObj)   unsigned int pCount;                                                                \
                                        objc_property_t* properties = class_copyPropertyList([self class], &pCount);        \
                                        if (properties)                                                                     \
                                        {                                                                                   \
                                            NSMutableArray *pArray      = [NSMutableArray arrayWithCapacity:pCount];        \
                                            for (int i = 0; i < pCount; i++)                                                \
                                            {                                                                               \
                                                [pArray addObject:@(property_getName(properties[i]))];                      \
                                            }                                                                               \
                                            free(properties);                                                               \
                                            for (int j = 0; j < pCount; j++)                                                \
                                            {                                                                               \
                                                NSString *pName = [pArray objectAtIndex:j];                                 \
                                                id value = [self valueForKey:pName];                                        \
                                                if ([value respondsToSelector:@selector(mutableCopyWithZone:)])             \
                                                {                                                                           \
                                                    [muCopyObj setValue:[value mutableCopy]                                 \
                                                                 forKey:pName];                                             \
                                                }                                                                           \
                                                else                                                                        \
                                                {                                                                           \
                                                    [muCopyObj setValue:value                                               \
                                                                 forKey:pName];                                             \
                                                }                                                                           \
                                            }                                                                               \
                                            [pArray removeAllObjects];                                                      \
                                        }

// 获取App属性
#define GOS_INFO_DICTIONARY [[NSBundle mainBundle] infoDictionary]

// 快速小范围定位 leak
#define GOS_QUICK_CHECK_LEAK    dispatch_async(dispatch_get_main_queue(), ^{                                                                                \
                                    NSArray<UIViewController*>*vcArray = self.navigationController.viewControllers;                                         \
                                    if (!vcArray || 0 >= vcArray.count)                                                                                     \
                                    {                                                                                                                       \
                                        return;                                                                                                             \
                                    }                                                                                                                       \
                                    [self.navigationController popToViewController:[vcArray objectAtIndex:(1 < vcArray.count) ? (vcArray.count - 2) : 0]   \
                                                                          animated:YES];                                                                    \
                                });

// 检查视频数据定时器时间间隔（单位：秒）
#define  CHECK_VIDEO_INTERVAL   5

// 检查设备温度定时器时间间隔（单位：秒）
#define  CHECK_TEMPERATURE_INTERVAL   60

// 视频渲染视图比例（高:宽 = 9:16 = 0.5625；高:宽 = 3:4 = 0.75)
#define GOS_VIDEO_H_W_SCALE     0.5625

// TUTK 推送‘非白名单’ key
#define TUTK_PUSH_NO_WHITE_KEY  @"TutkPushNOWhiteKey"

// 推送消息列表正在编辑标志
#define GOS_PUSHMSG_LIST_IS_EDITING    @"GosPushMsgListIsEditing"

// 已连接设备 ID 集合 key
#define GOS_HAS_CONN_SET_KEY    @"GosHasConnSetKey"

// 重新拉流次数，如果已连接设备拉流失败超过设定次数，则断开设备连接，重新建立设备连接
#define GOS_REOPEN_AV_STREAM_COUNTS     5

#endif /* MacroDefinition_h */
