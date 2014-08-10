//
//  BleManager.h
//  UpdateTool
//
//  Created by Vincent on 14/8/10.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ServicesManager.h"
#import "BleServicesAndCharacteristics.h"

@interface BleManager : NSObject<CBCentralManagerDelegate>

@property (nonatomic,strong)CBCentralManager *centralManager;
@property (nonatomic,strong)NSMutableArray *foundPeripherals;

+ (id)sharedInstance;
- (void)startScan;
- (void)stopScan;
-(void)connectPeripheral:(CBPeripheral*)peripheral;
@end
