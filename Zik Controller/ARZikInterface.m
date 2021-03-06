//
//  ARBluetoothInterface.m
//  Zik Controller
//
//  Created by Rui Araújo on 13/09/14.
//  Copyright (c) 2014 Rui Araújo. All rights reserved.
//

#import "ARZikInterface.h"

#import "AIObservable+ARZikController.h"
#import "ARZikApi.h"

#import <IOBluetooth/objc/IOBluetoothDevice.h>
#import <IOBluetooth/objc/IOBluetoothRFCOMMChannel.h>
#import <IOBluetooth/objc/IOBluetoothSDPServiceRecord.h>
#import <IOBluetooth/objc/IOBluetoothSDPUUID.h>
#import <IOBluetoothUI/objc/IOBluetoothDeviceSelectorController.h>

#import <TBXML/TBXML.h>


static const unsigned char ZikServiceClassUUID[] =	//0ef0f502-f0ee-46c9-986c-54ed027807fb
{
    0x0e, 0xf0, 0xf5, 0x02, 0xf0, 0xee, 0x46, 0xc9, 0x98, 0x6c, 0x54, 0xed, 0x02, 0x78, 0x07, 0xfb
};

#define REPLY_HEADER_COUNT      (7)

void newDevice(void * refCon, IOBluetoothUserNotificationRef inRef, IOBluetoothObjectRef objectRef)
{
    NSLog(@"Device connection change\n");
    ARZikInterface * interface = (__bridge id)refCon;
    IOBluetoothDevice *bluetoothDevice =(__bridge id)objectRef;
    if ( interface.connectionStatus == DISCONNECTED && [bluetoothDevice isConnected]){
        [interface searchForZikInConnectedDevices];
    }
}


@interface ARZikInterface ()
@property (nonatomic, strong) AIObservable* observable;
@end


@implementation ARZikInterface
@synthesize connectionStatus;

- (id)init {
    if (self = [super init]) {
        self.observable = [[AIObservable alloc] init];
        connectionStatus = DISCONNECTED;
        newDeviceNot = NULL;
    }
    return self;
}

+ (instancetype)instance {
    static ARZikInterface *sharedInterface = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInterface = [[self alloc] init];
    });
    return sharedInterface;
}

- (void)addObserver:(id<ARZikStatusObserver>)observer {
    [self.observable addObserver:observer];
}

- (void)removeObserver:(id<ARZikStatusObserver>)observer {
    [self.observable removeObserver:observer];
}

-(void)registerForNewDevices
{
    newDeviceNot = IOBluetoothRegisterForDeviceConnectNotifications(newDevice, (__bridge void*)self);
}


-(void)unregisterForNewDevices
{
    if (newDeviceNot != NULL){
        IOBluetoothUserNotificationUnregister(newDeviceNot);
        newDeviceNot = NULL;
    }
}

// Connection Method:
// returns TRUE if the connection was successful:
- (BOOL)searchForZikInConnectedDevices
{
    IOBluetoothSDPUUID					*serviceUUID;
    IOReturn							status;
    IOBluetoothSDPServiceRecord			*serviceRecord;
    
    if (connectionStatus != DISCONNECTED){
        return FALSE;
    }
    // Create an IOBluetoothSDPUUID object for the chat service UUID
    serviceUUID = [IOBluetoothSDPUUID uuidWithBytes:ZikServiceClassUUID length:16];
    
    
    NSArray *paired = [IOBluetoothDevice pairedDevices];
    for (id device in paired) {
        
        // Get the chat service record from the device the user has selected.
        // We can assume that the device selector performed an SDP query, so we can
        // just get the service record from the device's cache.
        serviceRecord = [device getServiceRecordForUUID:serviceUUID];
        if ( serviceRecord != nil ) {
            
            // To connect we need a device to connect and an RFCOMM channel ID to open on the device:
            status = [serviceRecord getRFCOMMChannelID:&rfcommChannelID];
            
            // Check to make sure the service record actually had an RFCOMM channel ID
            if ( status != kIOReturnSuccess )
            {
                NSLog( @"Error: 0x%lx getting RFCOMM channel ID from service.\n", (unsigned long)status );
                return FALSE;
            }
            
            // The service record contains all the useful information about the service the user selected
            // Just for fun we log its name:
            NSLog( @"Service selected '%@' - RFCOMM Channel ID = %d\n", [serviceRecord getServiceName], rfcommChannelID );
            if ( [device isConnected] ){
                selectedDevice = device;
                connectionStatus = CONNECTING;
                [self connectionComplete:kIOReturnSuccess];
                return TRUE;
            }
        }
        
    }
    return FALSE;
}

- (BOOL)connectToZik
{
    IOBluetoothDeviceSelectorController	*deviceSelector;
    IOBluetoothSDPUUID					*serviceUUID;
    NSArray								*deviceArray;
    IOBluetoothSDPServiceRecord			*serviceRecord;
    IOReturn							status;
    if (connectionStatus != DISCONNECTED){
        return FALSE;
    }
    
    connectionStatus = CONNECTING;
    // The device selector will provide UI to the end user to find a remote device
    deviceSelector = [IOBluetoothDeviceSelectorController deviceSelector];
    
    if ( deviceSelector == nil )
    {
        connectionStatus = DISCONNECTED;
        NSLog( @"Error - unable to allocate IOBluetoothDeviceSelectorController.\n" );
        return FALSE;
    }
    
    // Create an IOBluetoothSDPUUID object for the chat service UUID
    serviceUUID = [IOBluetoothSDPUUID uuidWithBytes:ZikServiceClassUUID length:16];
    
    // Tell the device selector what service we are interested in.
    // It will only allow the user to select devices that have that service.
    [deviceSelector addAllowedUUID:serviceUUID];
    
    // Run the device selector modal.  This won't return until the user has selected a device and the device has
    // been validated to contain the specified service or the user has hit the cancel button.
    if ( [deviceSelector runModal] != kIOBluetoothUISuccess )
    {
        connectionStatus = DISCONNECTED;
        NSLog( @"User has cancelled the device selection.\n" );
        return FALSE;    }
    
    // Get the list of devices the user has selected.
    // By default, only one device is allowed to be selected.
    deviceArray = [deviceSelector getResults];
    
    if ( ( deviceArray == nil ) || ( [deviceArray count] == 0 ) )
    {
        connectionStatus = DISCONNECTED;
        NSLog( @"Error - no selected device.  ***This should never happen.***\n" );
        return FALSE;
    }
    
    // Since only one device was allowed to be selected, we only care about the
    // first entry in the array.
    selectedDevice = [deviceArray objectAtIndex:0];
    
    // Get the chat service record from the device the user has selected.
    // We can assume that the device selector performed an SDP query, so we can
    // just get the service record from the device's cache.
    serviceRecord = [selectedDevice getServiceRecordForUUID:serviceUUID];
    
    if ( serviceRecord == nil )
    {
        connectionStatus = DISCONNECTED;
        NSLog( @"Error - no chat service in selected device.  ***This should never happen.***\n" );
        return FALSE;
    }
    
    // To connect we need a device to connect and an RFCOMM channel ID to open on the device:
    status = [serviceRecord getRFCOMMChannelID:&rfcommChannelID];
    
    // Check to make sure the service record actually had an RFCOMM channel ID
    if ( status != kIOReturnSuccess )
    {
        connectionStatus = DISCONNECTED;
        NSLog( @"Error: 0x%lx getting RFCOMM channel ID from service.\n", (unsigned long)status );
        return FALSE;
    }
    
    // The service record contains all the useful information about the service the user selected
    // Just for fun we log its name:
    NSLog( @"Service selected '%@' - RFCOMM Channel ID = %d\n", [serviceRecord getServiceName], rfcommChannelID );
    
    // Before we can open the RFCOMM channel, we need to open a connection to the device.
    // The openRFCOMMChannel... API probably should do this for us, but for now we have to
    // do it manually.
    status = [selectedDevice openConnection:self];
    
    [self connectionComplete:status];
    //TODO: the async api call to open connection is not working
    if ( status != kIOReturnSuccess )
    {
        return FALSE;
    }
    
    return TRUE;
    
}

// Disconnection:
// closes the channel:
- (void)disconnectFromZik
{
    if ( _mRFCOMMChannel != nil )
    {
        IOBluetoothDevice *device = [_mRFCOMMChannel getDevice];
        
        // This will close the RFCOMM channel and start an inactivity timer to close the baseband connection if no
        // other channels (L2CAP or RFCOMM) are open.
        [_mRFCOMMChannel closeChannel];
        _mRFCOMMChannel = nil;
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            // This signals to the system that we are done with the baseband connection to the device.  If no
            // other channels are open, it will immediately close the baseband connection.
            [device closeConnection];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //Run UI Updates
            });
        });
        connectionStatus = DISCONNECTED;
    }
}

// Send Data method
// returns TRUE if all the data was sent:
- (BOOL)sendData:(void*)buffer length:(NSUInteger)length
{
    if ( _mRFCOMMChannel != nil )
    {
        NSUInteger				numBytesRemaining;
        IOReturn			result;
        BluetoothRFCOMMMTU	rfcommChannelMTU;
        
        numBytesRemaining = length;
        result = kIOReturnSuccess;
        
        // Get the RFCOMM Channel's MTU.  Each write can only contain up to the MTU size
        // number of bytes.
        rfcommChannelMTU = [_mRFCOMMChannel getMTU];
        
        // Loop through the data until we have no more to send.
        while ( ( result == kIOReturnSuccess ) && ( numBytesRemaining > 0 ) )
        {
            // finds how many bytes I can send:
            NSUInteger numBytesToSend = ( ( numBytesRemaining > rfcommChannelMTU ) ? rfcommChannelMTU :  numBytesRemaining );
            
            // This method won't return until the buffer has been passed to the Bluetooth hardware to be sent to the remote device.
            // Alternatively, the asynchronous version of this method could be used which would queue up the buffer and return immediately.
            result = [_mRFCOMMChannel writeAsync:buffer length:numBytesToSend refcon:nil];
            
            // Updates the position in the buffer:
            numBytesRemaining -= numBytesToSend;
            buffer += numBytesToSend;
        }
        
        // We are successful only if all the data was sent:
        if ( ( numBytesRemaining == 0 ) && ( result == kIOReturnSuccess ) )
        {
            return TRUE;
        }
    }
    
    return FALSE;
}


-(void)refreshZikStatus
{
    [self ZikRequest:BATTERY_GET :nil];
    [self ZikRequest:SOUND_EFFECT_ENABLED_GET :nil];
    [self ZikRequest:NOISE_CANCELLATION_ENABLED_GET :nil];
    [self ZikRequest:CONCERT_HALL_GET :nil];
    [self ZikRequest:EQUALIZER_GET :nil];
}


-(void)refreshZikSystemPreferences
{
    [self ZikRequest:VERSION_GET :nil];
    [self ZikRequest:FRIENDLY_NAME_GET :nil];
    [self ZikRequest:SYSTEM_ANC_PHONE_MODE_GET :nil];
    [self ZikRequest:SYSTEM_AUTO_CONNECTION_GET :nil];
    [self ZikRequest:SYSTEM_HEAD_DETECTION_ENABLED_GET :nil];
    [self ZikRequest:SYSTEM_AUTO_POWER_OFF_LIST_GET :nil];
    [self ZikRequest:SYSTEM_AUTO_POWER_OFF_GET :nil];
}

-(BOOL)getFriendlyName
{
    return [self ZikRequest:FRIENDLY_NAME_GET :nil];
}



-(BOOL)setFriendlyName:(NSString*)newName
{
    return [self ZikRequest:FRIENDLY_NAME_SET :newName];
}

-(BOOL)setANCPhoneInCall:(BOOL)enabled
{
    if (enabled) {
        return [self ZikRequest:SYSTEM_ANC_PHONE_MODE_SET :@"true"];
    } else {
        return [self ZikRequest:SYSTEM_ANC_PHONE_MODE_SET :@"false"];
    }
}

-(BOOL)setAutoConnection:(BOOL)enabled
{
    if (enabled) {
        return [self ZikRequest:SYSTEM_AUTO_CONNECTION_SET :@"true"];
    } else {
        return [self ZikRequest:SYSTEM_AUTO_CONNECTION_SET :@"false"];
    }
}


-(BOOL)setAutoPowerOff:(NSUInteger)newValue
{
    return [self ZikRequest:SYSTEM_AUTO_POWER_OFF_SET :[NSString stringWithFormat: @"%ld", newValue]];
}


-(BOOL)setHeadDetection:(BOOL)enabled
{
    if (enabled) {
        return [self ZikRequest:SYSTEM_HEAD_DETECTION_ENABLED_SET :@"true"];
    } else {
        return [self ZikRequest:SYSTEM_HEAD_DETECTION_ENABLED_SET :@"false"];
    }
}

-(BOOL)setLouReedModeState:(BOOL)enabled
{
    if (enabled) {
        return [self ZikRequest:SOUND_EFFECT_ENABLED_SET :@"true"];
    } else {
        return [self ZikRequest:SOUND_EFFECT_ENABLED_SET :@"false"];
    }
}

-(BOOL)setActiveNoiseCancellationState:(BOOL)enabled
{
    if (enabled) {
        return [self ZikRequest:NOISE_CANCELLATION_ENABLED_SET :@"true"];
    } else {
        return [self ZikRequest:NOISE_CANCELLATION_ENABLED_SET :@"false"];
    }
}

-(BOOL)setConcertHallState:(BOOL)enabled
{
    if (enabled) {
        return [self ZikRequest:CONCERT_HALL_ENABLED_SET :@"true"];
    } else {
        return [self ZikRequest:CONCERT_HALL_ENABLED_SET :@"false"];
    }
}


-(BOOL)setConcertHallRoomSize:(RoomSize)room{
    NSString *roomArg = nil;
    switch (room) {
        case SILENT_ROOM:
            roomArg = @"silent";
            break;
            
        case LIVING_ROOM:
            roomArg = @"living";
            break;
            
        case JAZZ_ROOM:
            roomArg = @"jazz";
            break;
            
        case CONCERT_HALL:
            roomArg = @"concert";
            break;
            
        default:
            return false;
    }
    return [self ZikRequest:CONCERT_HALL_ROOM_SET :roomArg];
    
    
}

-(BOOL)setConcertHallAngle:(AngleEffect)angle{
    NSString *angleArg = nil;
    switch (angle) {
        case DEGREES_30:
            angleArg = @"30";
            break;
        case DEGREES_60:
            angleArg = @"60";
            break;
        case DEGREES_90:
            angleArg = @"90";
            break;
        case DEGREES_120:
            angleArg = @"120";
            break;
        case DEGREES_150:
            angleArg = @"150";
            break;
        case DEGREES_180:
            angleArg = @"180";
            break;
        default:
            return false;
    }
    return [self ZikRequest:CONCERT_HALL_ANGLE_SET :angleArg];
}

-(BOOL)setEqualizerState:(BOOL)enabled
{
    if (enabled) {
        return [self ZikRequest:EQUALIZER_ENABLED_SET :@"true"];
    } else {
        return [self ZikRequest:EQUALIZER_ENABLED_SET :@"false"];
    }
}

-(BOOL)setEqualizerPreset:(NSUInteger)preset
{
    return [self ZikRequest:EQUALIZER_PRESET_ID_SET :[NSString stringWithFormat:@"%li",  preset]];
}

+(OptionStatus)convertStatus:(NSString*)status
{
    if ([status isEqualToString:@"true"]){
        return ON;
    } else if ([status isEqualToString:@"invalid_on"]){
        return INVALID_ON;
    }else if ([status isEqualToString:@"invalid_off"]){
        return INVALID_OFF;
    }else {
        return OFF;
    }
}


+(RoomSize)convertRoom:(NSString*)room
{
    if ([room isEqualToString:@"silent"]){
        return SILENT_ROOM;
    } else if ([room isEqualToString:@"living"]){
        return LIVING_ROOM;
    }else if ([room isEqualToString:@"jazz"]){
        return JAZZ_ROOM;
    }else {
        return CONCERT_HALL;
    }
}

+(AngleEffect)convertAngle:(NSString*)angle
{
    if ([angle isEqualToString:@"30"]){
        return DEGREES_30;
    } else if ([angle isEqualToString:@"60"]){
        return DEGREES_60;
    }else if ([angle isEqualToString:@"90"]){
        return DEGREES_90;
    }else if ([angle isEqualToString:@"120"]){
        return DEGREES_120;
    }else if ([angle isEqualToString:@"150"]){
        return DEGREES_150;
    }else { //180
        return DEGREES_180;
    }
}


-(BOOL) ZikRequest:(NSString*)apicall :(NSString*)args
{
    NSString *request;
    if ( args == nil ) {
        request = [NSMutableString stringWithFormat:@"GET %@",apicall];
    } else {
        request = [NSMutableString stringWithFormat:@"SET %@?arg=%@",apicall, args];
    }
    unsigned char header[] = {0x00, 0x00, 0x80};
    unsigned short requestLength = [request length]+3;
    header[0] = (requestLength >> 8);
    header[1] = requestLength & 0xFF;
    
    NSMutableData *data1 = [NSMutableData dataWithBytes:[request UTF8String]  length:[request length]];
    [data1 replaceBytesInRange:NSMakeRange(0, 0) withBytes:(const void *)header length:3];
    return [self sendData:[data1 mutableBytes] length:[data1 length]];
}

// Implementation of delegate calls (see IOBluetoothRFCOMMChannel.h) Only the basic ones:
- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel*)rfcommChannel data:(void *)dP length:(size_t)dataLength;
{
    if ( dataLength < REPLY_HEADER_COUNT){
        return;
    }
    char * dataPointer = (char*)dP;
    NSData *data = [NSData dataWithBytes:dataPointer+REPLY_HEADER_COUNT length:dataLength-REPLY_HEADER_COUNT];
    NSString *reply = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@\n", reply);
    NSError *error;
    TBXML * tbxml = [TBXML newTBXMLWithXMLString:reply error:&error];
    if (error) {
        NSLog(@"%@ %@", [error localizedDescription], [error userInfo]);
        return;
    }
    NSString *rootName =[TBXML elementName:tbxml.rootXMLElement];
    NSString *path = [TBXML valueOfAttributeNamed:@"path" forElement:tbxml.rootXMLElement];
    if ( ![rootName isEqualToString:@"answer"]) {
        if ([rootName isEqualToString:@"notify"]) {
            [self ZikRequest:path :nil];
        }
        return;
    }
    if ( [path isEqualToString:BATTERY_GET] ){
        TBXMLElement *battery = [TBXML childElementNamed:@"battery" parentElement:[TBXML childElementNamed:@"system" parentElement:tbxml.rootXMLElement]];
        NSString *status= [TBXML valueOfAttributeNamed:@"state" forElement:battery];
        BOOL charging = [status isEqualToString:@"charging"];
        NSNumber *level = nil;
        if (!charging) {
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            level = [f numberFromString:[TBXML valueOfAttributeNamed:@"level" forElement:battery]];
        }
        
        [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(newBatteryStatus:level:) argCount:2 arguments:&charging,&level];
    } else if ( [path isEqualToString:SOUND_EFFECT_ENABLED_GET] ){
        TBXMLElement *audio = [TBXML childElementNamed:@"specific_mode" parentElement:[TBXML childElementNamed:@"audio" parentElement:tbxml.rootXMLElement]];
        OptionStatus status = [ARZikInterface convertStatus:[TBXML valueOfAttributeNamed:@"enabled" forElement:audio]];
        [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(LouReedModeState:) argCount:1 arguments:&status];
    } else if ( [path isEqualToString:NOISE_CANCELLATION_ENABLED_GET] ){
        TBXMLElement *audio = [TBXML childElementNamed:@"noise_cancellation" parentElement:[TBXML childElementNamed:@"audio" parentElement:tbxml.rootXMLElement]];
        OptionStatus status = [ARZikInterface convertStatus:[TBXML valueOfAttributeNamed:@"enabled" forElement:audio]];
        [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(ActiveNoiseCancellationState:) argCount:1 arguments:&status];
    } else if ( [path isEqualToString:CONCERT_HALL_ENABLED_GET] ){
        TBXMLElement *sound = [TBXML childElementNamed:@"sound_effect" parentElement:[TBXML childElementNamed:@"audio" parentElement:tbxml.rootXMLElement]];
        OptionStatus status = [ARZikInterface convertStatus:[TBXML valueOfAttributeNamed:@"enabled" forElement:sound]];
        [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(ConcertHallEffectState:) argCount:1 arguments:&status];
    } else if ( [path isEqualToString:CONCERT_HALL_GET] ){
        TBXMLElement *sound = [TBXML childElementNamed:@"sound_effect" parentElement:[TBXML childElementNamed:@"audio" parentElement:tbxml.rootXMLElement]];
        RoomSize room = [ARZikInterface convertRoom:[TBXML valueOfAttributeNamed:@"room_size" forElement:sound]];
        OptionStatus status = [ARZikInterface convertStatus:[TBXML valueOfAttributeNamed:@"enabled" forElement:sound]];
        AngleEffect angle = [ARZikInterface convertAngle:[TBXML valueOfAttributeNamed:@"angle" forElement:sound]];
        [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(ConcertHallEffectState:room :angle:) argCount:3 arguments:&status, &room, &angle];
    } else if ( [path isEqualToString:CONCERT_HALL_ROOM_GET] ){
        TBXMLElement *sound = [TBXML childElementNamed:@"sound_effect" parentElement:[TBXML childElementNamed:@"audio" parentElement:tbxml.rootXMLElement]];
        RoomSize room = [ARZikInterface convertRoom:[TBXML valueOfAttributeNamed:@"room_size" forElement:sound]];
        [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(ConcertHallEffectRoomSize:) argCount:1 arguments:&room];
    } else if ( [path isEqualToString:CONCERT_HALL_ANGLE_GET] ){
        TBXMLElement *sound = [TBXML childElementNamed:@"sound_effect" parentElement:[TBXML childElementNamed:@"audio" parentElement:tbxml.rootXMLElement]];
        AngleEffect angle = [ARZikInterface convertAngle:[TBXML valueOfAttributeNamed:@"angle" forElement:sound]];
        [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(ConcertHallEffectRoomSize:) argCount:1 arguments:&angle];
    } else if ( [path isEqualToString:EQUALIZER_ENABLED_GET] ){
        TBXMLElement *equ = [TBXML childElementNamed:@"equalizer" parentElement:[TBXML childElementNamed:@"audio" parentElement:tbxml.rootXMLElement]];
        OptionStatus status = [ARZikInterface convertStatus:[TBXML valueOfAttributeNamed:@"enabled" forElement:equ]];
        [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(EqualizerState:) argCount:1 arguments:&status];
    } else if ( [path isEqualToString:EQUALIZER_GET] ){
        TBXMLElement *equ = [TBXML childElementNamed:@"equalizer" parentElement:[TBXML childElementNamed:@"audio" parentElement:tbxml.rootXMLElement]];
        OptionStatus status = [ARZikInterface convertStatus:[TBXML valueOfAttributeNamed:@"enabled" forElement:equ]];
        NSUInteger preset= [[TBXML valueOfAttributeNamed:@"preset_id" forElement:equ]integerValue];
        [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(EqualizerState:preset:) argCount:2 arguments:&status, &preset];
    } else if ( [path isEqualToString:EQUALIZER_PRESET_ID_GET] ){
        TBXMLElement *equ = [TBXML childElementNamed:@"equalizer" parentElement:[TBXML childElementNamed:@"audio" parentElement:tbxml.rootXMLElement]];
        NSUInteger preset= [[TBXML valueOfAttributeNamed:@"preset_id" forElement:equ]integerValue];
        [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(EqualizerPreset:) argCount:1 arguments:&preset];
    } else if ( [path isEqualToString:SYSTEM_ANC_PHONE_MODE_GET] ){
        TBXMLElement *config = [TBXML childElementNamed:@"anc_phone_mode" parentElement:[TBXML childElementNamed:@"system" parentElement:tbxml.rootXMLElement]];
        OptionStatus status = [ARZikInterface convertStatus:[TBXML valueOfAttributeNamed:@"enabled" forElement:config]];
        [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(ANCPhoneCallState:) argCount:1 arguments:&status];
    } else if ( [path isEqualToString:SYSTEM_AUTO_POWER_OFF_GET] ){
        TBXMLElement *config = [TBXML childElementNamed:@"auto_power_off" parentElement:[TBXML childElementNamed:@"system" parentElement:tbxml.rootXMLElement]];
        NSInteger value = [[TBXML valueOfAttributeNamed:@"value" forElement:config] integerValue];
        [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(AutoPowerOffValue:) argCount:1 arguments:&value];
    } else if ( [path isEqualToString:SYSTEM_AUTO_POWER_OFF_LIST_GET] ){
        NSMutableArray* values = [[NSMutableArray alloc] init];
        TBXMLElement *config = [TBXML childElementNamed:@"auto_power_off" parentElement:[TBXML childElementNamed:@"system" parentElement:tbxml.rootXMLElement]];
        while (config != nil) {
            NSInteger value = [[TBXML valueOfAttributeNamed:@"preset_value" forElement:config] integerValue];
            [values addObject:[NSNumber numberWithInteger:value]];
            // Find next child element to process
            config = [TBXML nextSiblingNamed:@"auto_power_off" searchFromElement:config];
        }
        [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(AutoPowerOffValuesList:) argCount:1 arguments:&values];
    } else if ( [path isEqualToString:SYSTEM_AUTO_CONNECTION_GET] ){
        TBXMLElement *config = [TBXML childElementNamed:@"auto_connection" parentElement:[TBXML childElementNamed:@"system" parentElement:tbxml.rootXMLElement]];
        OptionStatus status = [ARZikInterface convertStatus:[TBXML valueOfAttributeNamed:@"enabled" forElement:config]];
        [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(AutoConnectionState:) argCount:1 arguments:&status];
    } else if ( [path isEqualToString:SYSTEM_HEAD_DETECTION_ENABLED_GET] ){
        TBXMLElement *config = [TBXML childElementNamed:@"head_detection" parentElement:[TBXML childElementNamed:@"system" parentElement:tbxml.rootXMLElement]];
        OptionStatus status = [ARZikInterface convertStatus:[TBXML valueOfAttributeNamed:@"enabled" forElement:config]];
        [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(HeadDetectionState:) argCount:1 arguments:&status];
    } else if ( [path isEqualToString:FRIENDLY_NAME_GET] ){
        TBXMLElement *config = [TBXML childElementNamed:@"bluetooth" parentElement:tbxml.rootXMLElement];
        NSString *name = [TBXML valueOfAttributeNamed:@"friendlyname" forElement:config];
        [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(FriendlyName:) argCount:1 arguments:&name];
    } else if ( [path isEqualToString:VERSION_GET] ){
        TBXMLElement *config = [TBXML childElementNamed:@"software" parentElement:tbxml.rootXMLElement];
        NSString *version = [TBXML valueOfAttributeNamed:@"version" forElement:config];
        [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(FirmwareVersion:) argCount:1 arguments:&version];
    }
    
}

- (void)rfcommChannelClosed:(IOBluetoothRFCOMMChannel*)rfcommChannel;
{
    connectionStatus = DISCONNECTED;
    _mRFCOMMChannel = nil;
    NSUInteger status = kIOReturnError;
    [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(newZikConnectionStatus:) argCount:1 arguments:&status];
}

-(void)connectionComplete:(IOReturn)status{
    IOBluetoothRFCOMMChannel *localRFCOMMChannel;
    if (status == kIOReturnSuccess){
        // Open the RFCOMM channel on the new device connection
        status = [selectedDevice openRFCOMMChannelAsync:&localRFCOMMChannel withChannelID:rfcommChannelID delegate:self];
        if ( status != kIOReturnSuccess )        {
            NSLog( @"Error: 0x%lx - unable to open RFCOMM channel.\n", (unsigned long)status );
            connectionStatus = DISCONNECTED;
            NSUInteger status = kIOReturnError;
            [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(newZikConnectionStatus:) argCount:1 arguments:&status];
        }
    } else {
        NSLog( @"Error: 0x%lx opening connection to device.\n", (unsigned long)status );
        connectionStatus = DISCONNECTED;
        [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(newZikConnectionStatus:) argCount:1 arguments:&status];
    }
}


- (void)rfcommChannelOpenComplete:(IOBluetoothRFCOMMChannel*)rfcommChannel status:(IOReturn)error{
    if (error == kIOReturnSuccess){
        _mRFCOMMChannel = rfcommChannel;
        const unsigned char init[] = { 0x00, 0x03, 0x00 };
        if ( ![self sendData:(void*)init length:3]) {
            NSLog(@"Error sending init sequence\n" );
        }
        connectionStatus = CONNECTED;
    } else{
        connectionStatus = DISCONNECTED;
    }
    [self.observable notifyObservers:@protocol(ARZikStatusObserver) selector:@selector(newZikConnectionStatus:) argCount:1 arguments:&error];
}


@end
