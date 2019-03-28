//  GosServiceFactory.m
//  CloudStoreSDK
//
//  Create by daniel.hu on 2018/12/11.
//  Copyright © 2018年 daniel. All rights reserved.

#import "GosServiceFactory.h"
#import "GosMediator.h"

@interface GosServiceFactory ()

@property (nonatomic, strong) NSMutableDictionary *serviceStorage;
@end

@implementation GosServiceFactory

#pragma mark - shared instance class method
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static GosServiceFactory *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GosServiceFactory alloc] init];
    });
    return sharedInstance;
}

#pragma mark - public method
- (id<GosServiceProtocol>)serviceWithIdentifier:(NSString *)identifier {
    if (![self.serviceStorage objectForKey:identifier]) {
        self.serviceStorage[identifier] = [self newServiceWithIdentifier:identifier];
    }
    return self.serviceStorage[identifier];
}

#pragma mark - private method
- (id<GosServiceProtocol>)newServiceWithIdentifier:(NSString *)identifier {
    // 固定在GosTargetServiceManager类中找identifier方法
    return [[GosMediator sharedInstance] performTarget:@"ServiceGenerator" action:identifier params:nil shouldCacheTarget:YES];
}

#pragma mark - getters
- (NSMutableDictionary *)serviceStorage {
    if (!_serviceStorage) {
        _serviceStorage = [NSMutableDictionary dictionary];
    }
    return _serviceStorage;
}
@end
