//
//  ARBluetoothInterface.h
//  Zik Controller
//
//  Created by Rui Araújo on 13/09/14.
//  Copyright (c) 2014 Rui Araújo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/objc/IOBluetoothRFCOMMChannel.h>


typedef NS_ENUM(NSInteger, ConnectionStatus) {
    DISCONNECTED,
    CONNECTING,
    CONNECTED
};

typedef NS_ENUM(NSInteger, OptionStatus) {
    ON,
    OFF,
    INVALID_OFF,
    INVALID_ON
};


typedef NS_ENUM(NSInteger, RoomSize) {
    SILENT_ROOM,
    LIVING_ROOM,
    JAZZ_ROOM,
    CONCERT_HALL
};


typedef NS_ENUM(NSInteger, AngleEffect) {
    DEGREES_180,
    DEGREES_150,
    DEGREES_120,
    DEGREES_90,
    DEGREES_60,
    DEGREES_30,
};

@protocol ARZikStatusObserver
@optional
-(void)newZikConnectionStatus:(IOReturn)status;
-(void)newBatteryStatus:(BOOL)charging level:(NSNumber*)level;
-(void)LouReedModeState:(OptionStatus)status;
-(void)ActiveNoiseCancellationState:(OptionStatus)status;
-(void)ConcertHallEffectState:(OptionStatus)status;
-(void)ConcertHallEffectState:(OptionStatus)status room:(RoomSize)room angle:(AngleEffect)angle;
-(void)ConcertHallEffectRoomSize:(RoomSize)room;
-(void)ConcertHallEffectAngle:(AngleEffect)angle;
-(void)EqualizerState:(OptionStatus)status;
-(void)EqualizerState:(OptionStatus)status preset:(NSUInteger)preset;
-(void)EqualizerPreset:(NSUInteger)preset;
-(void)ANCPhoneCallState:(OptionStatus)status;
-(void)AutoConnectionState:(OptionStatus)status;
-(void)AutoPowerOffValue:(NSUInteger)value;
-(void)AutoPowerOffValuesList:(NSArray*)list;
-(void)HeadDetectionState:(OptionStatus)status;
-(void)FriendlyName:(NSString*)name;
-(void)FirmwareVersion:(NSString*)version;
@end

@interface ARZikInterface : NSObject<IOBluetoothRFCOMMChannelDelegate> {
    UInt8 rfcommChannelID;
    IOBluetoothDevice *selectedDevice;
    IOBluetoothUserNotificationRef newDeviceNot;
}

@property (strong, nonatomic) IOBluetoothRFCOMMChannel	*mRFCOMMChannel;
@property (nonatomic, assign) ConnectionStatus connectionStatus;

+ (instancetype)instance;

-(void)registerForNewDevices;
-(void)unregisterForNewDevices;
// Connection Method:
// returns TRUE if the connection was successful:
- (BOOL)searchForZikInConnectedDevices;

// returns TRUE if the connection was successful:
- (BOOL)connectToZik;

// Disconnection:
// closes the channel:
- (void)disconnectFromZik;

-(void)refreshZikStatus;
-(void)refreshZikSystemPreferences;

//Functions to toggle the main functions
-(BOOL)setLouReedModeState:(BOOL)enabled;
-(BOOL)setActiveNoiseCancellationState:(BOOL)enabled;
-(BOOL)setConcertHallState:(BOOL)enabled;
-(BOOL)setEqualizerState:(BOOL)enabled;

//Configurations of the Concert Hall effect
-(BOOL)setConcertHallRoomSize:(RoomSize)room;
-(BOOL)setConcertHallAngle:(AngleEffect)angle;

//Configuration of the Equalizer //TODO: values configuration for the User
-(BOOL)setEqualizerPreset:(NSUInteger)preset;

//Minor settings
-(BOOL)setANCPhoneInCall:(BOOL)enabled;
-(BOOL)setAutoConnection:(BOOL)enabled;
-(BOOL)setHeadDetection:(BOOL)enabled;

-(BOOL)setAutoPowerOff:(NSUInteger)newValue;

-(BOOL)getFriendlyName;
-(BOOL)setFriendlyName:(NSString*)newName;

- (void)addObserver:(id<ARZikStatusObserver>)observer;
- (void)removeObserver:(id<ARZikStatusObserver>)observer;

@end
