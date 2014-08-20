//
//  ServicesManager.m
//  UpdateTool
//
//  Created by Vincent on 14/8/10.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

#import "ServicesManager.h"

@implementation ServicesManager
@synthesize useableServices,targetServiceUUID;

- (id)init{
    
    self = [super init];
    if (self) {
        
        targetServiceUUID = [BleConfig searchServiceUUIDs];
    }
    return self;
}

- (CBService*)getServiceOfUUID:(CBUUID*)uuid{
    
    for (CBService *service in useableServices) {
        if ([service.UUID isEqual:uuid]) {
            return service;
        }
    }
    return nil;
}

@end
