//
//  ORSBluetoothBoardViewController.h
//  DKBLE112 Demo
//
//  Created by Andrew Madsen on 1/8/13.
//  Copyright (c) 2013 Open Reel Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ORSBluetoothBoardViewController : UIViewController <CBPeripheralDelegate>

- (void)sendData:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic;

@property (nonatomic, strong) CBPeripheral *bluetoothPeripheral;
@property (nonatomic, copy, readonly) NSArray *characteristics;

// IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

// For subclasses to override

+ (CBUUID *)serviceUUID;
+ (NSArray *)characteristicUUIDs;
+ (BOOL)shouldPollForCharacteristic:(CBCharacteristic *)characteristic;

- (void)receivedNewData:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic;

@end
