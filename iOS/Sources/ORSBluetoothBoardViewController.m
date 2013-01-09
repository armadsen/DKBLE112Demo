//
//  ORSBluetoothBoardViewController.m
//  DKBLE112 Demo
//
//  Created by Andrew Madsen on 1/8/13.
//  Copyright (c) 2013 Open Reel Software. All rights reserved.
//

#import "ORSBluetoothBoardViewController.h"

@interface ORSBluetoothBoardViewController ()

@property (nonatomic, copy, readwrite) NSArray *characteristics;

@end

@implementation ORSBluetoothBoardViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.statusLabel.text = @"";
	
	[self startDiscovery];	
}

- (void)sendData:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic;
{
	[self.bluetoothPeripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

#pragma mark - Private

- (void)startDiscovery
{
	if (!self.bluetoothPeripheral) return;
	
	CBUUID *serviceUUID = [[self class] serviceUUID];
	[self.bluetoothPeripheral discoverServices:@[serviceUUID]];
}

- (void)presentError:(NSError *)error
{
	NSLog(@"%@", error);
	self.statusLabel.text = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
}

#pragma mark - For Subclasses

+ (CBUUID *)serviceUUID
{
	return nil;
}

+ (NSArray *)characteristicUUIDs
{
	return @[];
}

+ (BOOL)shouldPollForCharacteristic:(CBCharacteristic *)characteristic;
{
	return NO;
}

- (void)receivedNewData:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic
{
	
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, peripheral, error);
	if (error) return [self presentError:error];
	
	CBUUID *serviceUUID = [[self class] serviceUUID];
	NSIndexSet *matchingServiceIndexes = [peripheral.services indexesOfObjectsPassingTest:^BOOL(CBService *service, NSUInteger idx, BOOL *stop) {
		return [service.UUID isEqual:serviceUUID];
	}];
	if (![matchingServiceIndexes count])
	{
		self.statusLabel.text = @"Device does not offer any known services";
		return;
	}
	
	CBService *service = [[peripheral.services objectsAtIndexes:matchingServiceIndexes] lastObject];
	[self.bluetoothPeripheral discoverCharacteristics:[[self class] characteristicUUIDs] forService:service];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
	NSLog(@"%s %@ %@ %@", __PRETTY_FUNCTION__, peripheral, service, error);
	if (error) return [self presentError:error];
	
	NSArray *characteristicUUIDs = [[self class] characteristicUUIDs];
	NSIndexSet *matchingCharacteristicIndexes = [service.characteristics indexesOfObjectsPassingTest:^BOOL(CBCharacteristic *characteristic, NSUInteger idx, BOOL *stop) {
		return [characteristicUUIDs containsObject:characteristic.UUID];
	}];
	if (![matchingCharacteristicIndexes count])
	{
		self.statusLabel.text = @"Device does not offer any known characteristics";
		return;
	}
	
	self.characteristics = [service.characteristics objectsAtIndexes:matchingCharacteristicIndexes];
	for (CBCharacteristic *characteristic in self.characteristics)
	{
		if ([[self class] shouldPollForCharacteristic:characteristic])
		{
			[peripheral readValueForCharacteristic:characteristic];
		}
		else
		{
			[peripheral setNotifyValue:YES forCharacteristic:characteristic];
		}
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	NSLog(@"%s %@ %@ %@", __PRETTY_FUNCTION__, peripheral, characteristic, error);
	if (error) return [self presentError:error];
	
	NSLog(@"New value for characteristic: %@", characteristic.value);
	[self receivedNewData:characteristic.value forCharacteristic:characteristic];
	
	if ([[self class] shouldPollForCharacteristic:characteristic])
	{
		[peripheral performSelector:@selector(readValueForCharacteristic:) withObject:characteristic afterDelay:0.1];
	}
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
