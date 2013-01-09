//
//  ORSBluetoothCableReplacementViewController.m
//  DKBLE112 Demo
//
//  Created by Andrew Madsen on 1/8/13.
//  Copyright (c) 2013 Open Reel Software. All rights reserved.
//

#import "ORSBluetoothCableReplacementViewController.h"
#import "ORSBluetoothBoardSupport.h"

@interface ORSBluetoothCableReplacementViewController ()

@end

@implementation ORSBluetoothCableReplacementViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.outputTextView.text = @"";
}

#pragma mark - Public

- (IBAction)send:(id)sender
{
	NSData *dataToSend = [self.inputField.text dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	[self sendData:dataToSend forCharacteristic:[self.characteristics lastObject]];
}

#pragma mark - Overrides

+ (CBUUID *)serviceUUID
{
	return [CBUUID UUIDWithString:ORSBluetoothBoardCableReplacementServiceUUIDString];
}

+ (NSArray *)characteristicUUIDs
{
	return @[[CBUUID UUIDWithString:ORSBluetoothBoardCableReplacementCharacteristicUUIDString]];
}

- (void)receivedNewData:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic
{
	NSString *receivedString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	if (!receivedString) return NSLog(@"Unable to decode received data using ASCII: %@", data);
	self.outputTextView.text = [self.outputTextView.text stringByAppendingString:receivedString];
}

@end
