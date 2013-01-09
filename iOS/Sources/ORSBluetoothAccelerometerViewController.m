//
//  ORSBluetoothAccelerometerViewController.m
//  DKBLE112 Demo
//
//  Created by Andrew Madsen on 1/8/13.
//  Copyright (c) 2013 Open Reel Software. All rights reserved.
//

#import "ORSBluetoothAccelerometerViewController.h"
#import "ORSBluetoothBoardSupport.h"

@interface ORSBluetoothAccelerometerViewController ()

@end

@implementation ORSBluetoothAccelerometerViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.xValueLabel.text = @"";
	self.yValueLabel.text = @"";
	self.zValueLabel.text = @"";
}

+ (CBUUID *)serviceUUID
{
	return [CBUUID UUIDWithString:ORSBluetoothBoardAccelerometerServiceUUIDString];
}

+ (NSArray *)characteristicUUIDs
{
	return @[[CBUUID UUIDWithString:ORSBluetoothBoardAccelerometerXCharacteristicUUIDString],
			 [CBUUID UUIDWithString:ORSBluetoothBoardAccelerometerYCharacteristicUUIDString],
			 [CBUUID UUIDWithString:ORSBluetoothBoardAccelerometerZCharacteristicUUIDString]];
}

+ (BOOL)shouldPollForCharacteristic:(CBCharacteristic *)characteristic;
{
	return YES;
}

- (void)receivedNewData:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic
{
	NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, data, characteristic);
	
	if ([data length] < 2) return;
	
	int16_t value = *((int16_t *)[data bytes]);
	double accelerationInTermsOfG = 9.8 * ((double)value / 3900.0 );
	NSString *valueString = [NSString stringWithFormat:@"%0.3f", accelerationInTermsOfG];
	
	if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ORSBluetoothBoardAccelerometerXCharacteristicUUIDString]])
	{
		self.xValueLabel.text = valueString;
	}
	else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ORSBluetoothBoardAccelerometerYCharacteristicUUIDString]])
	{
		self.yValueLabel.text = valueString;
	}
	else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ORSBluetoothBoardAccelerometerZCharacteristicUUIDString]])
	{
		self.zValueLabel.text = valueString;
	}
}

@end
