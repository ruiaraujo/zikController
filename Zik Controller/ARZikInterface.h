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
-(void)newZikConnectionStatus:(IOReturn)status;
-(void)newBatteryStatus:(BOOL)charging level:(NSInteger)level;
-(void)LouReedModeState:(OptionStatus)status;
-(void)ActiveNoiseCancellationState:(OptionStatus)status;
-(void)ConcertHallEffectState:(OptionStatus)status;
-(void)ConcertHallEffectState:(OptionStatus)status room:(RoomSize)room angle:(AngleEffect)angle;
-(void)ConcertHallEffectRoomSize:(RoomSize)room;
-(void)ConcertHallEffectAngle:(AngleEffect)angle;
-(void)EqualizerState:(OptionStatus)status;
-(void)EqualizerState:(OptionStatus)status preset:(NSUInteger)preset;
-(void)EqualizerPreset:(NSUInteger)preset;
@end

@interface ARZikInterface : NSObject<IOBluetoothRFCOMMChannelDelegate> {
    UInt8 rfcommChannelID;
    IOBluetoothDevice *selectedDevice;
}

@property (strong, nonatomic) IOBluetoothRFCOMMChannel	*mRFCOMMChannel;
@property (nonatomic, assign) ConnectionStatus connectionStatus;

-(void)registerForNewDevices;
// Connection Method:
// returns TRUE if the connection was successful:
- (BOOL)searchForZikInConnectedDevices;


// returns TRUE if the connection was successful:
- (BOOL)connectToZik;

// Disconnection:
// closes the channel:
- (void)disconnectFromZik;

-(void)refreshZikStatus;


//Functions to toggle the main functions
-(BOOL)setLouReedModeState:(BOOL)enabled;
-(BOOL)setActiveNoiseCancellationState:(BOOL)enabled;
-(BOOL)setConcertHallState:(BOOL)enabled;
-(BOOL)setEqualizerState:(BOOL)enabled;

//Configurations of the Concert Hall effect
-(BOOL)setConcertHallRoomSize:(RoomSize)room;
-(BOOL)setConcertHallAngle:(AngleEffect)angle;


-(BOOL)setEqualizerPreset:(NSUInteger)preset;


- (void)addObserver:(id<ARZikStatusObserver>)observer;
- (void)removeObserver:(id<ARZikStatusObserver>)observer;


@end
