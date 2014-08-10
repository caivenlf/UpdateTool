//
//  pelAppDelegate.h
//  BluetoothMaster
//
//  Created by Vicent on 13-11-25.
//  Copyright (c) 2013年 providence. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void (^getWatchTime)(NSData *timeData);

typedef enum
{
    START_DFU = 1,
    INITIALIZE_DFU_PARAMS,
    RECEIVE_FIRMWARE_IMAGE,
    VALIDATE_FIRMWARE,
    ACTIVATE_RESET,
    RESET,
    REPORT_SIZE,
    REQUEST_RECEIPT,
    RESPONSE_CODE = 0x10,
    RECEIPT,
} DFUTargetOpcode;

typedef enum
{
    SUCCESS = 0x01,
    INVALID_STATE,
    NOT_SUPPORTED,
    DATA_SIZE_EXCEEDS_LIMIT,
    CRC_ERROR,
    OPERATION_FAILED,
} DFUTargetResponse;



/*
 ===========================================================================
 
 BleMessageCenterOut这个代理主要是从蓝牙的回调当中实现，实现此代理的对象，可以适时的检测到蓝牙连接状态的改变。
 
 ===========================================================================
*/

@protocol bleRfreshTableDelegate <NSObject>

@optional
-(void)scanningStart;
-(void)findPeripheral:(CBPeripheral*)peripheral;
-(void)scanningFinish;
-(void)connectionBuild;
-(void)connectionLost;
@end



@protocol BleMessageCenterOut <NSObject>

@optional

-(void)receiveData:(NSData*)data;
-(void)blePowerOff;
-(void)blePowerOn;
-(void)connectionLost;
-(void)connecting;
-(void)connectingFinish;
- (void)connectOtaFinish;
@end

//以下位更新OTA所用的代理
@protocol DFUTargetAdapterDelegate <NSObject>
- (void) didFinishDiscovery;
- (void) didWriteControlPoint;
- (void) didWriteDataPacket;
- (void) didReceiveResponse:(DFUTargetResponse) response forCommand:(DFUTargetOpcode) opcode;
- (void) didReceiveReceipt;
- (void) didConnect;
@end

@interface BluetoothMessageCenter : NSObject{
	
}



#pragma mark - properties

@property (assign,nonatomic)        id<BleMessageCenterOut> messageDelegate;
@property (assign,nonatomic)        id<DFUTargetAdapterDelegate> delegate;
@property (assign,nonatomic)        id<bleRfreshTableDelegate>bleTableDelegate;
@property (strong,nonatomic)        getWatchTime getTimeResult;


//foundPeripherals为搜索到的Peripheral，还没有发起连接，用来在TableView中显示。
@property (retain)NSMutableArray *foundPeripherals;
@property (nonatomic)BOOL isConnectedSuccess;

//已经链接上的周边设备。
@property (nonatomic,strong) NSMutableArray *connectedPH;
@property (nonatomic,strong) NSString *serviceType;


#pragma mark - Methods

- (void) scanningForDevice;
- (void) scanningOTAForDevice;
- (void) stopScanning;
+(id)sharedInstance;
-(void)connectPeripheral:(CBPeripheral*)peripheral;
-(void)startDiscoverService;
-(void)disconnect;


-(void)writeData:(NSData *)data;
-(void)writeDataToControlPointCharacteristic:(NSData *)data;
-(void)writeDataToPacketCharacteristic:(NSData *)data;
//链接到最后一次链接的周边设备
-(void)connectLastPeripheral;

//getWatchTime
-(void)getWatchCurrentTime:(getWatchTime)watchTime;



@end
