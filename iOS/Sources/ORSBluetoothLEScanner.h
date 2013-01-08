//
//  ORSBluetoothLEScanner.h
//  DKBLE112 Demo
//
//  Created by Andrew Madsen on 1/7/13.
//  Copyright (c) 2013 Open Reel Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ORSBluetoothLEScanner : NSObject <CBCentralManagerDelegate>

+ (id)sharedBluetoothLEScanner;

- (void)scan;

@property (nonatomic, readonly, getter = isScanning) BOOL scanning;
@property (nonatomic, readonly, getter = isBluetoothEnabled) BOOL bluetoothEnabled;
@property (nonatomic, strong, readonly) NSSet *detectedPeripherals;

@end
