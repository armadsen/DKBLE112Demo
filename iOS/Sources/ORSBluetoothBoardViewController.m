//
//  ORSBluetoothBoardViewController.m
//  DKBLE112 Demo
//
//  Created by Andrew Madsen on 1/8/13.
//  Copyright (c) 2013 Open Reel Software. All rights reserved.
//

#import "ORSBluetoothBoardViewController.h"
#import "ORSBluetoothBoardSupport.h"

@interface ORSBluetoothBoardViewController ()

@property (nonatomic, strong) CBCharacteristic *cableReplacementCharacteristic;

@end

@implementation ORSBluetoothBoardViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.statusLabel.text = @"";
	self.outputTextView.text = @"";
	
	[self startDiscovery];	
}

#pragma mark - Public

- (IBAction)send:(id)sender
{
	NSData *dataToSend = [self.inputField.text dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	[self.bluetoothPeripheral writeValue:dataToSend forCharacteristic:self.cableReplacementCharacteristic type:CBCharacteristicWriteWithResponse];
}

#pragma mark - Private

- (void)startDiscovery
{
	if (!self.bluetoothPeripheral) return;
	
	CBUUID *serviceUUID = [CBUUID UUIDWithString:ORSBluetoothBoardCableReplacementServiceUUIDString];
	[self.bluetoothPeripheral discoverServices:@[serviceUUID]];
}

- (void)presentError:(NSError *)error
{
	NSLog(@"%@", error);
	self.statusLabel.text = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, peripheral, error);
	if (error) return [self presentError:error];
	
	NSIndexSet *matchingServiceIndexes = [peripheral.services indexesOfObjectsPassingTest:^BOOL(CBService *service, NSUInteger idx, BOOL *stop) {
		return [service.UUID isEqual:[CBUUID UUIDWithString:ORSBluetoothBoardCableReplacementServiceUUIDString]];
	}];
	
	CBService *service = [[peripheral.services objectsAtIndexes:matchingServiceIndexes] lastObject];
	CBUUID *characteristicUUID = [CBUUID UUIDWithString:ORSBluetoothBoardCableReplacementCharacteristicUUIDString];
	[self.bluetoothPeripheral discoverCharacteristics:@[characteristicUUID] forService:service];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
	NSLog(@"%s %@ %@ %@", __PRETTY_FUNCTION__, peripheral, service, error);
	if (error) return [self presentError:error];
	
	NSIndexSet *matchingCharacteristics = [service.characteristics indexesOfObjectsPassingTest:^BOOL(CBCharacteristic *characteristic, NSUInteger idx, BOOL *stop) {
		return [characteristic.UUID isEqual:[CBUUID UUIDWithString:ORSBluetoothBoardCableReplacementCharacteristicUUIDString]];
	}];
	
	CBCharacteristic *chacteristic = [[service.characteristics objectsAtIndexes:matchingCharacteristics] lastObject];
	[peripheral setNotifyValue:YES forCharacteristic:chacteristic];
	self.cableReplacementCharacteristic = chacteristic;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	NSLog(@"%s %@ %@ %@", __PRETTY_FUNCTION__, peripheral, characteristic, error);
	if (error) return [self presentError:error];
	
	NSLog(@"New value for characteristic: %@", characteristic.value);
	NSString *receivedString = [[NSString alloc] initWithData:characteristic.value encoding:NSASCIIStringEncoding];
	if (!receivedString) return NSLog(@"Unable to decode received data using ASCII: %@", characteristic.value);
	self.outputTextView.text = [self.outputTextView.text stringByAppendingString:receivedString];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	NSLog(@"%s %@ %@ %@", __PRETTY_FUNCTION__, peripheral, characteristic, error);
	if (error) return [self presentError:error];
}

#pragma mark - Properties

- (void)setBluetoothPeripheral:(CBPeripheral *)peripheral
{
	if (peripheral != _bluetoothPeripheral)
	{
		_bluetoothPeripheral.delegate = nil;
		_bluetoothPeripheral = peripheral;
		_bluetoothPeripheral.delegate = self;
		if (self.isViewLoaded) [self startDiscovery];
	}
}

@end
