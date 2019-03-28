//
//  TFCRMediaModel.m
//  Goscom
//
//  Created by shenyuanluo on 2019/1/2.
//  Copyright © 2019 goscam. All rights reserved.
//

#import "TFCRMediaModel.h"
#import <objc/runtime.h>

@implementation TFCRMediaModel

#pragma mark -- NSCoding：编码
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    GOS_RUNTIME_ENCODE(aCoder);
}

#pragma mark -- NSCoding：解码
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        GOS_RUNTIME_DECODE(aDecoder);
    }
    return self;
}

#pragma mark -- NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    id copyObj = [[[self class] allocWithZone:zone] init];
    if (copyObj)
    {
        GOS_RUNTIME_COPY(copyObj);
    }
    return copyObj;
}

#pragma mark -- NSMutableCopying
- (id)mutableCopyWithZone:(NSZone *)zone
{
    id muCopyObj = [[[self class] allocWithZone:zone] init];
    if (muCopyObj)
    {
        GOS_RUNTIME_MUCOPY(muCopyObj);
    }
    return muCopyObj;
}

- (BOOL)isEqual:(id)object
{
    if (!object || ![object isKindOfClass:[self class]])
    {
        return NO;
    }
    if (self == object)
    {
        return YES;
    }
    return [self isEqualToTFCMedia:object];
}

- (BOOL)isEqualToTFCMedia:(TFMediaFileModel *)media
{
    if (!media)
    {
        return NO;
    }
    // 特殊情况：如果两个媒体文件 设备ID、文件名 相同，则认为两个媒体文件模型相等
    TFMediaFileModel *tfmFile1 = [self valueForKey:@"tfmFile"];
    TFMediaFileModel *tfmFile2 = [media valueForKey:@"tfmFile"];
    
    return [tfmFile1 isEqual:tfmFile2];
}

@end
