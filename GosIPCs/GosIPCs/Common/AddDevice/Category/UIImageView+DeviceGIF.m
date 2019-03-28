//
//  UIImageView+DeviceGIF.m
//  Goscom
//
//  Created by 罗乐 on 2018/12/20.
//  Copyright © 2018 goscam. All rights reserved.
//

#import "UIImageView+DeviceGIF.h"
#import "UIImage+Gif.h"

@implementation UIImageView (DeviceGIF)

- (BOOL)playGIFWithDeviceID:(NSString *)devID {
    devID = [devID substringToIndex:5];
    NSString *gifName;
    
    if ([devID hasSuffix:@"A5"]
        || [devID hasSuffix:@"E5"]
        || [devID hasSuffix:@"L6"]
        ) {
        gifName = @"GD8202";
    }
    else if([devID hasSuffix:@"66"]
            || [devID hasSuffix:@"N5"]) {
        gifName = @"T5600";
    }
    else if([devID hasSuffix:@"35"]
            || [devID hasSuffix:@"15"]
            || [devID hasSuffix:@"H5"]
            ) {
        gifName = @"T5708";
    }
    else if([devID hasSuffix:@"55"]) {
        gifName = @"T5808";
    }
    else if([devID hasSuffix:@"Q6"]
            || [devID hasSuffix:@"T6"]) {
        gifName = @"T5825";
    }
    else if([devID hasSuffix:@"85"]
            || [devID hasSuffix:@"96"]
            || [devID hasSuffix:@"W6"]
            || [devID hasSuffix:@"G5"]
            || [devID hasSuffix:@"74"]) {
        gifName = @"T5826";
    } else if ([devID hasSuffix:@"75"]
               || [devID hasSuffix:@"Z6"]
               || [devID hasSuffix:@"76"]) {
        gifName = @"T5820";
    }
    else if([devID hasSuffix:@"45"]
            || [devID hasSuffix:@"05"]
            || [devID hasSuffix:@"I5"]) {
        gifName = @"T5830";
    }
    else if([devID hasSuffix:@"36"]
            || [devID hasSuffix:@"26"]
            || [devID hasSuffix:@"95"]
            || [devID hasSuffix:@"C5"]) {
        gifName = @"T5880";
    }
    else if([devID hasSuffix:@"86"]
            || [devID hasSuffix:@"46"]
            || [devID hasSuffix:@"I6"]
            || [devID hasSuffix:@"M6"]
            || [devID hasSuffix:@"R6"]
            || [devID hasSuffix:@"S6"]
            || [devID hasSuffix:@"V6"]
            || [devID hasSuffix:@"X6"]
            || [devID hasSuffix:@"65"]
            || [devID hasSuffix:@"D5"]
            || [devID hasSuffix:@"T5"]
            ) {
        gifName = @"T5886带温度";
        //是否有温度判断
    }
    else if([devID hasSuffix:@"B6"]
            || [devID hasSuffix:@"J5"]
            ) {
        gifName = @"T5900";
    }
    else if([devID hasSuffix:@"K5"]) {
        gifName = @"T5902";
    }
    else if([devID hasSuffix:@"A4"]) {
        gifName = @"T5703HCA";
    }
    else if([devID hasSuffix:@"B4"])
    {
        gifName = @"T5821HCA";
    }
    else if([devID hasSuffix:@"24"])
    {
        gifName = @"T5105JCA";
    }
    
    
    
    if (gifName != nil && gifName.length > 0) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:gifName ofType:@"gif"];
        NSData* imageData = [NSData dataWithContentsOfFile:filePath];
        self.image = [UIImage animatedGIFWithData:imageData];
        return YES;
    } else {
        return NO;
    }
}
@end
