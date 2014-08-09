//
//  OTAUpdateSys.h
//  YFWatch
//
//  Created by Vincent on 14-7-24.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

#define DFUCONTROLLER_MAX_PACKET_SIZE 20
#define DFUCONTROLLER_DESIRED_NOTIFICATION_STEPS 80

typedef enum
{
    INIT,
    DISCOVERING,
    IDLE,
    SEND_NOTIFICATION_REQUEST,
    SEND_START_COMMAND,
    SEND_RECEIVE_COMMAND,
    SEND_FIRMWARE_DATA,
    SEND_VALIDATE_COMMAND,
    SEND_RESET,
    WAIT_RECEIPT,
    FINISHED,
    CANCELED,
} DFUControllerState;

typedef struct __attribute__((packed))
{
    uint8_t opcode;
    union
    {
        uint16_t n_packets;
        struct __attribute__((packed))
        {
            uint8_t   original;
            uint8_t   response;
        };
        uint32_t n_bytes;
    };
} dfu_control_point_data_t;

#import <Foundation/Foundation.h>
#import "BluetoothMessageCenter.h"

@protocol OTAUpdateDelegate <NSObject>

- (void)receiveDataProgress:(float)progress;

@end


@interface OTAUpdateSys : NSObject

//ota
@property (nonatomic) DFUControllerState state;
@property int notificationPacketInterval;
@property NSData *firmwareData;
@property NSString *appName;
@property int firmwareDataBytesSent;
@property int appSize;
@property (nonatomic,assign)id<OTAUpdateDelegate>updateDelegate;

+ (instancetype)shareInstance;

- (void)updateSystem:(NSString *)sysName;
@end
