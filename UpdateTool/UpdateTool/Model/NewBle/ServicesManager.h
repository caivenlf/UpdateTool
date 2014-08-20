//
//  ServicesManager.h
//  UpdateTool
//
//  Created by Vincent on 14/8/10.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BleConfig.h"

@interface ServicesManager : NSObject

@property (nonatomic,strong) NSMutableArray *useableServices;
@property (nonatomic,strong) NSArray *targetServiceUUID;

- (CBService*)getServiceOfUUID:(CBUUID*)uuid;

@end
