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

@property (nonatomic, strong) CBPeripheral *bluetoothPeripheral;

@end
