//
//  GosPlatformDevIdDefine.h
//  GosIPCs
//
//  Created by shenyuanluo on 2018/12/4.
//  Copyright © 2018 goscam. All rights reserved.
//

#ifndef GosPlatformDevIdDefine_h
#define GosPlatformDevIdDefine_h


/*
 GOS 平台设备 ID 定义（即自主平台 8 个 字符解析）
 长度：a. 15 个字符；4.0 平台    例如：Z999621*******2
      b. 20 个字符；TUTK 平台   例如：JMCG68**********111A
      c. 28 个字符；3.5 平台（自主平台<8 个字符> + TUTK 平台<20 个字符>）   例如：Z9996100JMCG68**********111A
 
 例子：
 */

/** （平台 ID 第 1 位） 区域标识 枚举 */
typedef NS_ENUM(NSInteger, GosPIDAreaType) {
    GosPIDArea_unknown              = 0x30,        // ‘0’ 未知
    GosPIDArea_domestic             = 0x41,        // 'A'
    GosPIDArea_overseas             = 0x5A,        // 'Z'
};

/** （平台 ID 第 2、3 位） 客户类型 枚举 */
typedef NS_ENUM(NSInteger, GosPIDAgentType) {
    GosPIDAgent_unknown             = 0x3030,       // ‘00’ 未知
    GosPIDAgent_zhong               = 0x3939,       // '99' 中性
    GosPIDAgent_caiYi               = 0x3839,       // '89' 彩易
    GosPIDAgent_haiEr               = 0x3739,       // '79' 海尔
    GosPIDAgent_keAn                = 0x3639,       // '69' 科安
    GosPIDAgent_voxx                = 0x3539,       // '59' VOXX
};

/** （平台 ID 第 4、5 位） 设备类型 枚举 */
typedef NS_ENUM(NSInteger, GosPIDDevType) {
    GosDEV_unknown                  = 0x3030,       // ‘00’ 未知
    
    GosIpc_T5708HAA                 = 0x3335,       // '35'
    GosIpc_T5830HAA                 = 0x3435,       // '45'
    GosIpc_T5808HCA                 = 0x3535,       // '55'
    GosIpc_T5886HAD                 = 0x3635,       // '65'

    GosIpc_T5810HAA_                = 0x3835,       // '85'
    GosIpc_T5880HAC                 = 0x3935,       // '95'
    
    GosIpc_T5922HAA                 = 0x3036,       // '06'
    GosIpc_T5925HCA                 = 0x3136,       // '16'
    GosIpc_5880HAB                  = 0x3236,       // '26'
    GosIpc_T5880HCA                 = 0x3336,       // '36'
    GosIpc_T5886HAB                 = 0x3436,       // '46'
    GosIpc_T5703GAA                 = 0x3536,       // '56'
    
    GosIpc_T5820HCA                 = 0x3736,       // '76'
    GosIpc_T5886HAA                 = 0x3836,       // '86'
    GosIpc_T5826HAA                 = 0x3936,       // '96'
    GosIpc_T5923HAA                 = 0x4136,       // 'A6'
    GosIpc_T5900HAB                 = 0x4236,       // 'B6'
    GosIpc_T5901HAA                 = 0x4336,       // 'C6'
    GosIpc_GD6505_v200              = 0x4436,       // 'D6'
    
    GosIpc_T5800HAA_V200            = 0x4736,       // 'G6'
    GosIpc_T5703GAB                 = 0x4836,       // 'H6'
    GosIpc_T5886GAB                 = 0x4936,       // 'I6'
    GosIpc_T5705HAA                 = 0x4A36,       // 'J6'
    GosIpc_GD5818YD                 = 0x4B36,       // 'K6'
    GosIpc_8202KE                   = 0x4C36,       // 'L6'
    GosIpc_T5886HCB                 = 0x4D36,       // 'M6'
    GosIpc_U5887                    = 0x4E36,       // 'N6'
    GosIpc_T5100ZJ                  = 0x4F36,       // 'O6'
    GosIpc_T5810HAA                 = 0x5036,       // 'P6'
    GosIpc_T5825HAA                 = 0x5136,       // 'Q6'
    GosIpc_T5886GCB                 = 0x5236,       // 'R6'
    GosIpc_T5886GAC                 = 0x5336,       // 'S6'
    GosIpc_T5825HAB                 = 0x5436,       // 'T6'
    GosIpc_T2858ACA                 = 0x5536,       // 'U6'
    GosIpc_T5886HAE                 = 0x5636,       // 'V6'
    GosIpc_T5826HAB                 = 0x5736,       // 'W6'
    GosIpc_T5886HAF                 = 0x5836,       // 'X6'
    GosIpc_T5818HCA                 = 0x5936,       // 'Y6'
    GosIpc_T5820GBA                 = 0x5A36,       // 'Z6'
    
    GosPano_180_5820HCA             = 0x3735,       // '75'
    GosPano_360_T5600HCA            = 0x3636,       // '66'
    GosNvr_nvr                      = 0x4536,       // 'E6'
};

/** （平台 ID 第 6 位） 媒体服务器类型 枚举 */
typedef NS_ENUM(NSInteger, GosPIDMediaServerType) {
    GosPIDMediaS_unknown            = 0x30,         // ‘0’ 未知
    GosPIDMediaS_tutk               = 0x31,         // '1'  TUTK 平台
    GosPIDMediaS_4_0_p2p            = 0x32,         // '2'  P2P 打洞
    GosPIDMediaS_4_0_tcp            = 0x33,         // '3'  TCP 转发
};

/** （平台 ID 第 7、8 位） 媒体服务器类型 枚举 */   // 目前保留位


#endif /* GosPlatformDevIdDefine_h */
