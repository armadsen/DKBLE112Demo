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

- (IBAction)send:(id)sender;

@property (nonatomic, strong) CBPeripheral *bluetoothPeripheral;

// IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UITextView *outputTextView;

@end
