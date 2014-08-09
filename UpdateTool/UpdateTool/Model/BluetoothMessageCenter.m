//
//  pelAppDelegate.h
//  BluetoothMaster
//
//  Created by Vicent on 13-11-25.
//  Copyright (c) 2013年 providence. All rights reserved.
//

//6e400001-b5a3-f393-e0a9-e50e24dcca9e
//6e400001-b5a3-f393-e0a9-77656c6f6f70
//自定义协议
#define SERVICESTRING @"6e400001-b5a3-f393-e0a9-77656c6f6f70"
#define READCHARACTERISTIC @"6e400003-b5a3-f393-e0a9-77656c6f6f70"
#define WRITECHARACTERISTIC @"6e400002-b5a3-f393-e0a9-77656c6f6f70"
//更新固件的自定义协议
#define UPDATESYSTEMSERVICE @"00001530-1212-EFDE-1523-785FEABCD123"
#define UPDATECONTROLCHARACTERISTIC @"00001531-1212-EFDE-1523-785FEABCD123"
#define UPDATEPACKETCHARACTERISTIC @"00001532-1212-EFDE-1523-785FEABCD123"
//电池标准协议
#define BATTERYSERVICE @"180F"
#define BATTERYCHARCTERISTIC @"2A19"
//设备信息服务标准协议
#define DVINFOSERVICE @"180A"
#define DVMANUFACTURECHARCTERISTIC @"2A29"
#define DVMODELNUMBERCHARCTERISTIC @"2A24"
#define DVSERIALNUMBERCHARCTERISTIC @"2A25"
#define DVHARDWARECHARCTERISTIC @"2A27"
#define DVSOFTWARECHARCTERISTIC @"2A28"
//时间服务标准协议
#define TIMESERVICE @"1805"
#define TIMECHARACTERISTIC @"2A2B"



#import "BluetoothMessageCenter.h"


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

@interface BluetoothMessageCenter () <CBCentralManagerDelegate, CBPeripheralDelegate> {
	
	
	CBCentralManager    *centralManager;
	

	CBPeripheral *currentConnectPeripheral;

	
	NSString *kServiceUUIDString ;
	NSString *kReadCharacteristicUUIDString ;
	NSString *kWriteCharacteristicUUIDString;
	
	
	CBService			*readWriteService;
	CBCharacteristic    *readCharacteristic;
    CBCharacteristic	*writeCharacteristic;
    CBCharacteristic    *timeCharacteristic;
	
	
	CBUUID              *readUUID;
    CBUUID              *writeUUID;
    
    //以下是更新OTA需要的UUID
    CBUUID              *serviceOfOTA;
    CBUUID              *controlPointCharacteristicUUID;
    CBUUID              *packetCharacteristicUUID;
    //时间UUID
    CBUUID              *serviceOfTime;
    CBUUID              *timeCharacteristicUUID;
    //电池UUID
    CBUUID              *serviceOfBattery;
    CBUUID              *batteryCharacteristicUUID;
    //设备信息UUID
    CBUUID              *serviceOfDVInfo;
    CBUUID              *manufactureCharacteristicUUID;
    CBUUID              *serialNumberCharacteristicUUID;
    CBUUID              *hardwareCharacteristicUUID;
    CBUUID              *softwareCharacteristicUUID;
    CBUUID              *modelCharacteristicUUID;
}

@property CBCharacteristic *controlPointCharacteristic;
@property CBCharacteristic *packetCharacteristic;
@end


@implementation BluetoothMessageCenter
@synthesize messageDelegate,delegate,bleTableDelegate,foundPeripherals,connectedPH,isConnectedSuccess,getTimeResult;

//------------------------------First Step----------------------------


/*

 ===========================================================================
 
 以下方法为调用对象和初始化参数，单例模式（sharedInstance），调用代码可以如下：
 
 [[BluetoothMessageCenter sharedInstance] scanningForDevice]；
 
 ===========================================================================
*/
+ (id) sharedInstance
{
	static BluetoothMessageCenter *this	= nil;
	
	if (!this)
		
		this = [[BluetoothMessageCenter alloc] init];
	
	return this;
}

- (id) init
{
    self = [super init];
    if (self) {
		
        isConnectedSuccess = NO;
        
		foundPeripherals = [[NSMutableArray alloc] init];
        
        connectedPH = [[NSMutableArray alloc] init];
		
		kServiceUUIDString = SERVICESTRING;
		
		kReadCharacteristicUUIDString = READCHARACTERISTIC;
		
		kWriteCharacteristicUUIDString = WRITECHARACTERISTIC;
		
		writeUUID	= [CBUUID UUIDWithString:kWriteCharacteristicUUIDString];
        
		readUUID	= [CBUUID UUIDWithString:kReadCharacteristicUUIDString] ;
        
        
        //以下是更新OTA需要的UUID
        serviceOfOTA = [CBUUID UUIDWithString:UPDATESYSTEMSERVICE];
        controlPointCharacteristicUUID = [CBUUID UUIDWithString:UPDATECONTROLCHARACTERISTIC];
        packetCharacteristicUUID = [CBUUID UUIDWithString:UPDATEPACKETCHARACTERISTIC];
        //以下是时间UUID
        serviceOfTime = [CBUUID UUIDWithString:TIMESERVICE];
        timeCharacteristicUUID = [CBUUID UUIDWithString:TIMECHARACTERISTIC];
        //以下是电池UUID
        serviceOfBattery = [CBUUID UUIDWithString:BATTERYSERVICE];
        batteryCharacteristicUUID = [CBUUID UUIDWithString:BATTERYCHARCTERISTIC];
        //以下是获取手表固件信息UUID
        serviceOfDVInfo = [CBUUID UUIDWithString:DVINFOSERVICE];
        manufactureCharacteristicUUID = [CBUUID UUIDWithString:DVMANUFACTURECHARCTERISTIC];
        serialNumberCharacteristicUUID = [CBUUID UUIDWithString:DVSERIALNUMBERCHARCTERISTIC];
        hardwareCharacteristicUUID = [CBUUID UUIDWithString:DVHARDWARECHARCTERISTIC];
        softwareCharacteristicUUID = [CBUUID UUIDWithString:DVSOFTWARECHARCTERISTIC];
        modelCharacteristicUUID = [CBUUID UUIDWithString:DVMODELNUMBERCHARCTERISTIC];
        
		
		//初始化CBCentralManager，并设置代理为self。
		centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
		
	}
	
    return self;
	
}













//------------------------------Second Step----------------------------

/*
 ===========================================================================
 
 - (void) scanningForDevice：开始查找设备的方法，用户需要手动调用以便开始查询蓝牙设备。
 
 参数：uuidArray，option为搜索的时候需要传入的参数，缩小查询的范围，如果没有，为Nil。
 
 ===========================================================================
*/
#pragma mark -
#pragma mark own methods

- (void) scanningOTAForDevice{
    
    NSArray			*uuidArray	= [NSArray arrayWithObjects:serviceOfOTA, nil];
	
	NSDictionary	*options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
	
	[centralManager scanForPeripheralsWithServices:uuidArray options:options];
	
//	NSLog(@"BluetoothMessageCenter: Start Scanning for device with:00001530-1212-EFDE-1523-785FEABCD123");
    
	
	//搜索3秒后停止搜索。
//	[NSTimer scheduledTimerWithTimeInterval:15 target: self selector:@selector(stopScanning) userInfo:nil repeats:NO];
	
	//当刷新搜索结果的时候，我们清除所有的foundPeripherals，以便显示重新查找的数据。
	[foundPeripherals removeAllObjects];
	
	
	//回调查询开始方法。
	if (bleTableDelegate!=nil) {
		
		[bleTableDelegate scanningStart];
	}

}

- (void) scanningForDevice
{
	
	
	NSArray			*uuidArray	= [NSArray arrayWithObjects:[CBUUID UUIDWithString:kServiceUUIDString],serviceOfOTA, nil];
	
	NSDictionary	*options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
	
	[centralManager scanForPeripheralsWithServices:uuidArray options:options];
	
//	NSLog(@"BluetoothMessageCenter: Start Scanning for device with:%@", kServiceUUIDString);

	
	//搜索5秒后停止搜索。
	[NSTimer scheduledTimerWithTimeInterval:15 target: self selector:@selector(stopScanning) userInfo:nil repeats:NO];
	
	//当刷新搜索结果的时候，我们清除所有的foundPeripherals，以便显示重新查找的数据。
	[foundPeripherals removeAllObjects];

}
- (void) stopScanning
{
	[centralManager stopScan];
//	NSLog(@"BluetoothMessageCenter: Stop Scanning for devices");
	
	//finish scanning
	if (bleTableDelegate!=nil) {
		
		[bleTableDelegate scanningFinish];
	}
}














//-----------------------------Third Step---------------------------
/*
 ===========================================================================
 
 发起连接的指令。
 
 ===========================================================================
 
*/



/*
 ===========================================================================
 
 当每次只连接一个的时候，我们在连接另外蓝牙设备的时候，断开当前连接。
 
 ==========================================================================
 
*/
-(void)connectPeripheral:(CBPeripheral*)peripheral{
	
	if(currentConnectPeripheral){
		
		[centralManager cancelPeripheralConnection:currentConnectPeripheral];
	}
	
	currentConnectPeripheral = peripheral;
	
	[centralManager connectPeripheral:peripheral options:nil];
	
}


- (void) connectLastPeripheral{
    
    NSArray			*uuidArray	= [NSArray arrayWithObjects:[CBUUID UUIDWithString:SERVICESTRING],nil];
    
    [connectedPH removeAllObjects];
    
    connectedPH = [NSMutableArray arrayWithArray:[centralManager retrieveConnectedPeripheralsWithServices:uuidArray]];


    if([connectedPH count]>0){
        
        for(int i=0;i<[connectedPH count];i++){
            
            if([[[connectedPH objectAtIndex:i] name] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"lastConnectedPHName"]]){
                
                [centralManager connectPeripheral:[connectedPH objectAtIndex:i] options:nil];
            }
        }
    }
}
-(void)connectCurrentPeripheral{
    
    if(currentConnectPeripheral !=nil){
        
       [centralManager connectPeripheral:currentConnectPeripheral options:nil];
    }
}





#pragma mark -
#pragma mark CBCentralMangerDelegate


//这个方法是在创建Manager和设置代理成功之后调用的。
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
	switch ([centralManager state]) {
		case CBCentralManagerStatePoweredOff:
		{
            if ([messageDelegate respondsToSelector:@selector(blePowerOff)]) {
                [messageDelegate blePowerOff];
            }
			break;
		}
            
        case CBCentralManagerStateUnsupported:
        {
            break;
        }
            
		case CBCentralManagerStateUnauthorized:
		{
			
			break;
		}
            
		case CBCentralManagerStateUnknown:
		{
	
			break;
		}
            
		case CBCentralManagerStatePoweredOn:
		{
            
            if ([messageDelegate respondsToSelector:@selector(blePowerOn)]) {
                [messageDelegate blePowerOn];
            }
//            [self performSelector:@selector(reConnectLastPeripheral) withObject:nil afterDelay:5.0];
            
			break;
		}
            
		case CBCentralManagerStateResetting:
		{
			
			break;
		}
	}
}




/*
 ===========================================================================
 
 这个回调是在Scan结束之后调用的，每找到一个Peripheral，就会调用一次这个方法。
 
 foundPeripherals数组在Scan结束之后调用以下方法被填充。
 
 ===========================================================================
*/
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSMutableDictionary *peripheralDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    NSString* rssiStr = [numberFormatter stringFromNumber:RSSI];
    
    [peripheralDic setObject:peripheral forKey:PeripheralKey];
    [peripheralDic setObject:rssiStr forKey:PeripheralRssiKey];
    
	if (![foundPeripherals containsObject:peripheralDic]) {
		
		[foundPeripherals addObject:peripheralDic];
        
		if (bleTableDelegate!=nil) {
			
			[bleTableDelegate findPeripheral:peripheral];
		}
	}
}








/*
 ===========================================================================
 
     以下方法是在用户点击某个按钮之后，触发了connectPeripheral：方法之后开始连接。
 
     连接成功后，将当前的peripheral赋值给currentConnectPeripheral，currentConnectPeripheral然后开始查找自己的特征值。
 
	currentConnectPeripheral在这个时候被填充，并设置currentConnectPeripheral的代理为Self，以便查询周边的相关细节。例如：服务和特征值
 
 ===========================================================================
*/

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	currentConnectPeripheral = peripheral;
    
	//保存最后一次的链接周边名称。
    [[NSUserDefaults standardUserDefaults]setObject:[peripheral name] forKey:@"lastConnectedPHName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
	if (bleTableDelegate!=nil) {
		
		[bleTableDelegate connectionBuild];
	}
    if(delegate!=nil){
        
        [delegate didConnect];
    }
	
	[self startDiscoverService];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
    //断开后重新连接
//    [self performSelector:@selector(reConnectCurrentPeripheral) withObject:nil afterDelay:5.0];
}

//查找currentConnectPeripheral里面的Services
- (void) startDiscoverService
{
	CBUUID	*serviceUUID	= [CBUUID UUIDWithString:kServiceUUIDString];
    
	NSArray	*serviceArray	= [NSArray arrayWithObjects:serviceUUID,serviceOfOTA,serviceOfTime,serviceOfBattery,serviceOfDVInfo,nil];
	
	[currentConnectPeripheral setDelegate:self];
	
	[currentConnectPeripheral discoverServices:serviceArray];
}


//当连接未成功或者蓝牙断开的时候，系统调用以下方法。
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
	
    kSaveUserSystemObject(@"isConnected", @(0));
    isConnectedSuccess = NO;
//	NSLog(@"BluetoothMessageCenter: didDisconnectPeripheral%@",error);
		
//	currentConnectPeripheral = nil;
	
	if (messageDelegate!=nil) {
		
		[messageDelegate connectionLost];
	}
    if(bleTableDelegate != nil){
        
        [bleTableDelegate connectionLost];
    }
//    [self performSelector:@selector(reConnectCurrentPeripheral) withObject:nil afterDelay:5.0];
}

//断开后重新连接
-(void)reConnectCurrentPeripheral{
    
    [self connectCurrentPeripheral];
}
-(void)reConnectLastPeripheral{
    
    [self connectLastPeripheral];
}

#pragma mark -
#pragma mark CBPeripheralDelegate

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	NSArray		*services	= nil;
	
	NSArray		*uuids	= [NSArray arrayWithObjects:readUUID, writeUUID, nil];
	
	services = [peripheral services];
	
	if (!services || ![services count]) {
		return ;
	}
	
//	NSLog(@"BluetoothMessageCenter: didDiscoverServices");
	
	readWriteService = nil;
	
	for (CBService *curService in services) {
		
		if ([[curService UUID] isEqual:[CBUUID UUIDWithString:kServiceUUIDString]]) {
			
            self.serviceType = NormalServiceType;
			readWriteService = curService;
			[peripheral discoverCharacteristics:uuids forService:readWriteService];

		}else if ([[curService UUID] isEqual:serviceOfOTA]){
            
            self.serviceType = OTAServiceType;
            [peripheral discoverCharacteristics:@[controlPointCharacteristicUUID, packetCharacteristicUUID] forService:curService];
        }else if ([[curService UUID] isEqual:serviceOfTime]){
            
            [peripheral discoverCharacteristics:@[timeCharacteristicUUID] forService:curService];
        }else if ([[curService UUID]isEqual:serviceOfBattery]){
            
            [peripheral discoverCharacteristics:@[batteryCharacteristicUUID] forService:curService];
        }else if ([[curService UUID] isEqual:serviceOfDVInfo]){
            
            [peripheral discoverCharacteristics:@[manufactureCharacteristicUUID,serialNumberCharacteristicUUID,hardwareCharacteristicUUID,softwareCharacteristicUUID,modelCharacteristicUUID] forService:curService];
        }
	}
}







/*
 ===================================================================================================
 
 以下方法：当查找到特征值的时候，当为。。。。。
 
 ===================================================================================================
*/
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
	NSArray	*characteristics = [service characteristics];
	
	CBCharacteristic *characteristic;
	
	for (characteristic in characteristics) {
		
		if ([[characteristic UUID] isEqual:writeUUID]) { // write
			NSLog(@"---------------------->connectedPeripheralName:%@",peripheral.name);
			
            kSaveUserSystemObject(@"isConnected", @(1));
            NSLog(@"Discovered write Characteristic");
			
			writeCharacteristic = characteristic;
		
			[currentConnectPeripheral setNotifyValue:YES forCharacteristic:writeCharacteristic];
			
		}else if ([[characteristic UUID] isEqual:readUUID]){ // read
			
			NSLog(@"Discovered  read Characteristic");
			
			readCharacteristic = characteristic;
	
			[currentConnectPeripheral setNotifyValue:YES forCharacteristic:readCharacteristic];
            
            isConnectedSuccess = YES;
		}else if ([characteristic.UUID isEqual:controlPointCharacteristicUUID])
        {
            kSaveUserSystemObject(@"isConnected", @(1));
            //储存当前固件版本
            [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"softwareVersion"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"Discovered control point characteristic.");
            self.controlPointCharacteristic = characteristic;
            
            [currentConnectPeripheral setNotifyValue:YES forCharacteristic:self.controlPointCharacteristic];
            isConnectedSuccess = YES;
        }
        else if ([characteristic.UUID isEqual:packetCharacteristicUUID])
        {
            NSLog(@"Discovered packet characteristic.");
            self.packetCharacteristic = characteristic;
        }else if ([characteristic.UUID isEqual:timeCharacteristicUUID]){
            
            timeCharacteristic = characteristic;
            NSLog(@"Discovered  time Characteristic");
            NSLog(@"time = %@",characteristic.value);
        }else if ([characteristic.UUID isEqual:batteryCharacteristicUUID]){
            NSLog(@"Discovered  battery Characteristic");
            NSLog(@"%@",characteristic.value);
        }else if ([characteristic.UUID isEqual:manufactureCharacteristicUUID]){
            NSLog(@"Discovered  manufacture Characteristic");
            NSLog(@"%@",characteristic.value );
        }else if ([characteristic.UUID isEqual:serialNumberCharacteristicUUID]){
            NSLog(@"Discovered  serialNumber Characteristic");
            NSLog(@"%@",characteristic.value);
        }else if ([characteristic.UUID isEqual:hardwareCharacteristicUUID]){
            NSLog(@"Discovered  hardware Characteristic");
            NSLog(@"%@",characteristic.value);
            [currentConnectPeripheral readValueForCharacteristic:characteristic];
        }else if ([characteristic.UUID isEqual:softwareCharacteristicUUID]){
            
            NSLog(@"Discovered  software Characteristic");
            NSLog(@"%@",characteristic.value);
            [currentConnectPeripheral readValueForCharacteristic:characteristic];
        }else if ([characteristic.UUID isEqual:modelCharacteristicUUID]){
            [currentConnectPeripheral readValueForCharacteristic:characteristic];
            NSLog(@"Discovered  model Characteristic");
            
            NSLog(@"model  :%@",[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
        }
	}
    
    if (self.packetCharacteristic && self.controlPointCharacteristic)
    {
        if([self.delegate respondsToSelector:@selector(didFinishDiscovery)]){
            
            [delegate didFinishDiscovery];
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([[characteristic UUID] isEqual:readUUID]) {
        
        NSLog(@"***receive Data***:%@",[characteristic value]);
    }
    
    if ([characteristic.UUID isEqual:controlPointCharacteristicUUID])
    {
        dfu_control_point_data_t *packet = (dfu_control_point_data_t *) characteristic.value.bytes;
        if (packet->opcode == RESPONSE_CODE)
        {
            [self.delegate didReceiveResponse:packet->response forCommand:packet->original];
        }
        if (packet->opcode == RECEIPT)
        {
            [self.delegate didReceiveReceipt];
        }
    }else if([[characteristic UUID] isEqual:hardwareCharacteristicUUID]){
    
        NSData *data = characteristic.value;
        NSString *result = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, [data length])] encoding:NSUTF8StringEncoding];
        NSLog(@"hardware Version num:%@",result);
        
    }else if([[characteristic UUID] isEqual:softwareCharacteristicUUID]){

        NSData *data = characteristic.value;
        NSString *result = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, [data length])] encoding:NSUTF8StringEncoding];
        NSLog(@"sorftware Version num:%@",result);
    }else if ([[characteristic UUID] isEqual:timeCharacteristicUUID]){
        
        NSData *data = characteristic.value;
        getTimeResult(data);
    }

	if([messageDelegate respondsToSelector:@selector(receiveData:)]){
		
		[messageDelegate receiveData:[characteristic value]];
	}
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{

    if([[characteristic UUID] isEqual:writeUUID]){
        
        NSString *str = [NSString stringWithFormat:@"%@",[characteristic value]];
        NSLog(@"***Send Data***:%@",str);
    }
    
    if (characteristic == self.controlPointCharacteristic)
    {
        if([self.delegate respondsToSelector:@selector(didWriteControlPoint)]){
            
            [delegate didWriteControlPoint];
        }
    }
    
	if(error){
		
		NSLog(@"BluetoothMessageCenter: didWriteValueForCharacteristic %@",error);
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if ([[characteristic UUID] isEqual:writeUUID]){
        
        if([messageDelegate respondsToSelector:@selector(connectingFinish)]){
            
            [messageDelegate connectingFinish];
        }
    }else if ([[characteristic UUID] isEqual:controlPointCharacteristicUUID]){
        
        if([messageDelegate respondsToSelector:@selector(connectOtaFinish)]){
            
            [messageDelegate connectOtaFinish];
        }
    }
}




/*
 ===========================================================================
 
 
 
 ===========================================================================
 */


-(void)disconnect{
	
	if(currentConnectPeripheral){
		
		[centralManager cancelPeripheralConnection:currentConnectPeripheral];
	}else{
		
		
	}
	
}

-(void)writeData:(NSData *)data{

        [currentConnectPeripheral writeValue:data forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
}
-(void)writeDataToControlPointCharacteristic:(NSData *)data{

    [currentConnectPeripheral writeValue:data forCharacteristic:_controlPointCharacteristic type:CBCharacteristicWriteWithResponse];
}
-(void)writeDataToPacketCharacteristic:(NSData *)data{

    [currentConnectPeripheral writeValue:data forCharacteristic:_packetCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

-(void)getWatchCurrentTime:(getWatchTime)watchTime{
    
    getTimeResult = watchTime;
    [currentConnectPeripheral readValueForCharacteristic:timeCharacteristic];

}

@end