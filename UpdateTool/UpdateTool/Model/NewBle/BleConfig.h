//
//  BleConfig.h
//  UpdateTool
//
//  Created by Vincent on 14/8/11.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BleServicesAndCharacteristics.h"

@interface BleConfig : NSObject

/**
    @func the service's uuid which will be searched/the ble sign
 */
+ (NSArray *)searchServiceUUIDs;

@end
