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

@protocol ARBluetoothDelegate
- (void)zikConnectionComplete:(IOReturn)error;
- (void)newBatteryStatus:(BOOL)charging :(NSInteger)level;
@end

@interface ARZikInterface : NSObject<IOBluetoothRFCOMMChannelDelegate> {
    UInt8 rfcommChannelID;
    IOBluetoothDevice *selectedDevice;
}

@property (strong, nonatomic) IOBluetoothRFCOMMChannel	*mRFCOMMChannel;
@property (nonatomic, assign) id  delegate;
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

-(void)updateBatteryStatus;

@end
