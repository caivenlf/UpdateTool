//
//  BleServicesAndCharacteristics.h
//  UpdateTool
//
//  Created by Vincent on 14/8/10.
//  Copyright (c) 2014年 Vicent. All rights reserved.
//

/**
 自定义协议
 */
#define SERVICES_NORMAL             @"6e400001-b5a3-f393-e0a9-77656c6f6f70"
#define READCHARACTERISTIC          @"6e400003-b5a3-f393-e0a9-77656c6f6f70"
#define WRITECHARACTERISTIC         @"6e400002-b5a3-f393-e0a9-77656c6f6f70"
/**
 OTA自定义协议
 */
#define SERVICES_OTA                @"00001530-1212-EFDE-1523-785FEABCD123"
#define UPDATECONTROLCHARACTERISTIC @"00001531-1212-EFDE-1523-785FEABCD123"
#define UPDATEPACKETCHARACTERISTIC  @"00001532-1212-EFDE-1523-785FEABCD123"
/**
 电池标准协议
 */
#define BATTERYSERVICE              @"180F"
#define BATTERYCHARCTERISTIC        @"2A19"
/**
 设备信息服务标准协议
 */
#define DVINFOSERVICE               @"180A"
#define DVMANUFACTURECHARCTERISTIC  @"2A29"
#define DVMODELNUMBERCHARCTERISTIC  @"2A24"
#define DVSERIALNUMBERCHARCTERISTIC @"2A25"
#define DVHARDWARECHARCTERISTIC     @"2A27"
#define DVSOFTWARECHARCTERISTIC     @"2A28"
/**
 时间服务标准协议
 */
#define TIMESERVICE                 @"1805"
#define TIMECHARACTERISTIC          @"2A2B"


/**
 生成UUID
*/
#define kCREATEUUIDFROMSTRING(UUIDSTR)   [CBUUID UUIDWithString:UUIDSTR]