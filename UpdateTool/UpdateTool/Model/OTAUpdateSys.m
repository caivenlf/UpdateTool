//
//  OTAUpdateSys.m
//  YFWatch
//
//  Created by Vincent on 14-7-24.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

#import "OTAUpdateSys.h"

@implementation OTAUpdateSys
@synthesize state = _state,updateDelegate;
//进入OTA之后的升级模式
#pragma mark -
#pragma mark Delegate
+ (instancetype)shareInstance{
    
    static OTAUpdateSys *this	= nil;
	
	if (!this)
		
		this = [[OTAUpdateSys alloc] init];
	
	return this;
}

- (void)updateSystem:(NSString *)sysName{
    
    [[BluetoothMessageCenter sharedInstance] setDelegate:self];
    
    self.state = IDLE;
    
    NSURL *firmwareURL = [[NSBundle mainBundle] URLForResource:sysName withExtension:@"bin"];
    
    [self setFirmwareURL:firmwareURL];
    
    [self startTransfer];
}
- (void) didFinishDiscovery{
    
    //    NSLog(@"didFinishDiscovery");
    if (self.state == DISCOVERING)
    {
        self.state = IDLE;
    }
}
-(void)didConnect{
    
    //    NSLog(@"didConnect");
    if (self.state == INIT)
    {
        self.state = DISCOVERING;
    }
}
- (void) didWriteControlPoint{
    switch (self.state)
    {
        case SEND_NOTIFICATION_REQUEST:
            self.state = SEND_START_COMMAND;
            [self sendStartCommand:(int)self.firmwareData.length];
            break;
            
        case SEND_RECEIVE_COMMAND:
            self.state = SEND_FIRMWARE_DATA;
            [self sendFirmwareChunk];
            break;
            
        case SEND_RESET:
            self.state = FINISHED;
            break;
            
        case CANCELED:
            break;
        default:
            break;
    }
}
- (void) didWriteDataPacket{
    if (self.state == SEND_FIRMWARE_DATA)
    {
        self.state = WAIT_RECEIPT;
    }
}
- (void) didReceiveResponse:(DFUTargetResponse) response forCommand:(DFUTargetOpcode) opcode{
    switch (self.state)
    {
        case SEND_START_COMMAND:
            if (response == SUCCESS)
            {
                self.state = SEND_RECEIVE_COMMAND;
                [self sendReceiveCommand];
            }
            break;
        case SEND_VALIDATE_COMMAND:
            if (response == SUCCESS)
            {
                self.state = SEND_RESET;
                [self sendResetAndActivate:YES];
            }
            break;
        case WAIT_RECEIPT:
            if (response == SUCCESS && opcode == RECEIVE_FIRMWARE_IMAGE)
            {
                self.state = SEND_VALIDATE_COMMAND;
                [self sendValidateCommand];
            }
            break;
        default:
            break;
    }
}
- (void) didReceiveReceipt{
    if (self.state == WAIT_RECEIPT)
    {
        float progress = self.firmwareDataBytesSent / ((float) self.firmwareData.length)+0.05;
        if ([updateDelegate respondsToSelector:@selector(receiveDataProgress:)]) {
            
            [updateDelegate receiveDataProgress:progress];
        }
        self.state = SEND_FIRMWARE_DATA;
        [self sendFirmwareChunk];
    }
}
- (void) startTransfer
{
    if (self.state == IDLE)
    {
        self.state = SEND_NOTIFICATION_REQUEST;
        [self sendNotificationRequest:self.notificationPacketInterval];
    }
}
- (void) setFirmwareURL:(NSURL *)firmwareURL
{
    self.firmwareData = [NSData dataWithContentsOfURL:firmwareURL];
    self.notificationPacketInterval = self.firmwareData.length / (DFUCONTROLLER_MAX_PACKET_SIZE * DFUCONTROLLER_DESIRED_NOTIFICATION_STEPS);
    self.appName = firmwareURL.path.lastPathComponent;
    self.appSize = self.firmwareData.length;
    
    //    NSLog(@"Set firmware with size %lu, notificationPacketInterval: %d", (unsigned long)self.firmwareData.length, self.notificationPacketInterval);
}
- (void) sendFirmwareChunk
{
    //    NSLog(@"sendFirmwareData");
    int currentDataSent = 0;
    for (int i = 0; i < self.notificationPacketInterval && self.firmwareDataBytesSent < self.firmwareData.length; i++)
    {
        unsigned long length = (self.firmwareData.length - self.firmwareDataBytesSent) > DFUCONTROLLER_MAX_PACKET_SIZE ? DFUCONTROLLER_MAX_PACKET_SIZE : self.firmwareData.length - self.firmwareDataBytesSent;
        
        NSRange currentRange = NSMakeRange(self.firmwareDataBytesSent, length);
        NSData *currentData = [self.firmwareData subdataWithRange:currentRange];
        [self sendFirmwareData:currentData];
        self.firmwareDataBytesSent += length;
        currentDataSent += length;
    }
    
    [self didWriteDataPacket];
    
    NSLog(@"Sent %d bytes, total %d.", currentDataSent, self.firmwareDataBytesSent);
}

- (void) setState:(DFUControllerState)newState
{
    @synchronized(self)
    {
        DFUControllerState oldState = _state;
        _state = newState;
        if (newState == INIT)
        {
            self.firmwareDataBytesSent = 0;
        }
    }
}
- (DFUControllerState) state
{
    return _state;
}
//ota
- (void) sendNotificationRequest:(int) interval
{
    //    NSLog(@"sendNotificationRequest");
    dfu_control_point_data_t data;
    data.opcode = REQUEST_RECEIPT;
    data.n_packets = interval;
    
    NSData *commandData = [NSData dataWithBytes:&data length:3];
    [[BluetoothMessageCenter sharedInstance] writeDataToControlPointCharacteristic:commandData];
}
- (void) sendStartCommand:(int) firmwareLength
{
    //    NSLog(@"sendStartCommand");
    dfu_control_point_data_t data;
    data.opcode = START_DFU;
    
    NSData *commandData = [NSData dataWithBytes:&data length:1];
    [[BluetoothMessageCenter sharedInstance] writeDataToControlPointCharacteristic:commandData];
    
    NSData *sizeData = [NSData dataWithBytes:&firmwareLength length:sizeof(firmwareLength)];
    [[BluetoothMessageCenter sharedInstance] writeDataToPacketCharacteristic:sizeData];
}
- (void) sendReceiveCommand
{
    //    NSLog(@"sendReceiveCommand");
    dfu_control_point_data_t data;
    data.opcode = RECEIVE_FIRMWARE_IMAGE;
    
    NSData *commandData = [NSData dataWithBytes:&data length:1];
    [[BluetoothMessageCenter sharedInstance] writeDataToControlPointCharacteristic:commandData];
}
- (void) sendFirmwareData:(NSData *) data
{
    [[BluetoothMessageCenter sharedInstance] writeDataToPacketCharacteristic:data];
}
- (void) sendValidateCommand
{
    //    NSLog(@"sendValidateCommand");
    dfu_control_point_data_t data;
    data.opcode = VALIDATE_FIRMWARE;
    
    NSData *commandData = [NSData dataWithBytes:&data length:1];
    [[BluetoothMessageCenter sharedInstance] writeDataToControlPointCharacteristic:commandData];
}
- (void) sendResetAndActivate:(BOOL)activate
{
    dfu_control_point_data_t data;
    if (activate)
    {
        data.opcode = ACTIVATE_RESET;
    }
    else
    {
        data.opcode = RESET;
    }
    NSData *commandData = [NSData dataWithBytes:&data length:1];
    [[BluetoothMessageCenter sharedInstance] writeDataToControlPointCharacteristic:commandData];
}



@end
