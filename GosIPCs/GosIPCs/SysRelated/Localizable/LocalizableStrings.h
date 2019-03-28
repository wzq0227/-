//
//  LocalizableStrings.h
//  Goscom
//
//  Created by shenyuanluo on 2018/11/12.
//  Copyright © 2018 shenyuanluo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocalizableStrings : NSObject

+ (NSString *)LocalizedString:(NSString *)translation_key;

@end

NS_ASSUME_NONNULL_END
