//
//  BleConfig.m
//  UpdateTool
//
//  Created by Vincent on 14/8/11.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

#import "BleConfig.h"

@implementation BleConfig

+ (NSArray *)searchServiceUUIDs{
    
    return @[kCREATEUUIDFROMSTRING(SERVICES_NORMAL),kCREATEUUIDFROMSTRING(SERVICES_OTA)];
}


@end
