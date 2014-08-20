//
//  BleManager.m
//  UpdateTool
//
//  Created by Vincent on 14/8/10.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

#import "BleManager.h"

@interface BleManager(){
    
    ServicesManager *servicesManager;
    CBPeripheral *wantPeripheral;
}
@end

@implementation BleManager
@synthesize centralManager,foundPeripherals;

+ (id)sharedInstance{
    
    static BleManager *this;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        this = [[BleManager alloc] init];
    });
    return this;
}

- (id)init{
    
    self = [super init];
    if (self) {
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        servicesManager = [[ServicesManager alloc] init];
    }
    return self;
}

#pragma mark - Self Method
- (void)startScan{
    
    NSArray	*serviceUUIDs=servicesManager.targetServiceUUID;
    NSDictionary *scanOptions= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    [centralManager scanForPeripheralsWithServices:serviceUUIDs options:scanOptions];
}

- (void)stopScan{
    
    [centralManager stopScan];
}

-(void)connectPeripheral:(CBPeripheral*)peripheral{

    wantPeripheral = peripheral;
    [centralManager connectPeripheral:peripheral options:nil];
}

- (void) startDiscoverService
{
    CBUUID	*serviceUUID	= [CBUUID UUIDWithString:kServiceUUIDString];
    
    NSArray	*serviceArray	= [NSArray arrayWithObjects:serviceUUID,serviceOfOTA,serviceOfTime,serviceOfBattery,serviceOfDVInfo,nil];
    
    [currentConnectPeripheral setDelegate:self];
    
    [currentConnectPeripheral discoverServices:serviceArray];
}

#pragma mark - Bluetooth Delegate
//bluetoothCenterManger's delegate required
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    switch ([centralManager state]) {
        case CBCentralManagerStatePoweredOff:
            break;
        case CBCentralManagerStatePoweredOn:
            break;
        case CBCentralManagerStateUnsupported:
            break;
        case CBCentralManagerStateUnauthorized:
            break;
        case CBCentralManagerStateUnknown:
            break;
        case CBCentralManagerStateResetting:
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    if (![foundPeripherals containsObject:peripheral]) {
        [foundPeripherals addObject:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"didConnectPeripheral");
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"didDisconnectPeripheral");
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"didFailToConnectPeripheral");
}

@end
