//  NSURLRequest+GosNetworkingMethod.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "NSURLRequest+GosNetworkingMethod.h"
#import <objc/runtime.h>

@implementation NSURLRequest (GosNetworkingMethod)

- (void)setActualRequestParams:(NSDictionary *)actualRequestParams {
    objc_setAssociatedObject(self, @selector(actualRequestParams), actualRequestParams, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSDictionary *)actualRequestParams {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setOriginRequestParams:(NSDictionary *)originRequestParams {
    objc_setAssociatedObject(self, @selector(originRequestParams), originRequestParams, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSDictionary *)originRequestParams {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setService:(id<GosServiceProtocol>)service {
    objc_setAssociatedObject(self, @selector(service), service, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<GosServiceProtocol>)service {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setUploadProcess:(void (^)(NSProgress * _Nonnull))uploadProcess {
    objc_setAssociatedObject(self, @selector(uploadProcess), uploadProcess, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(NSProgress * _Nonnull))uploadProcess {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDownloadProcess:(void (^)(NSProgress * _Nonnull))downloadProcess {
    objc_setAssociatedObject(self, @selector(downloadProcess), downloadProcess, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(NSProgress * _Nonnull))downloadProcess {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDestination:(NSURL * _Nonnull (^)(NSURL * _Nonnull, NSURLResponse * _Nonnull))destination {
    objc_setAssociatedObject(self, @selector(destination), destination, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSURL * _Nonnull (^)(NSURL * _Nonnull, NSURLResponse * _Nonnull))destination {
    return objc_getAssociatedObject(self, _cmd);
}
@end
