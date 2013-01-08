//
//  ORSBluetoothLEScanner.m
//  DKBLE112 Demo
//
//  Created by Andrew Madsen on 1/7/13.
//  Copyright (c) 2013 Open Reel Software. All rights reserved.
//

#import "ORSBluetoothLEScanner.h"

static ORSBluetoothLEScanner *sharedBluetoothLEScanner;

@interface ORSBluetoothLEScanner ()

@property (nonatomic, readwrite, getter = isScanning) BOOL scanning;
@property (nonatomic, readwrite, getter = isBluetoothEnabled) BOOL bluetoothEnabled;
@property (nonatomic, copy) NSMutableSet *internalDetectedPeripherals;
- (void)addInternalDetectedPeripheral:(id)anInternalDetectedPeripheral;
- (void)removeInternalDetectedPeripheral:(id)anInternalDetectedPeripheral;

@property (nonatomic, strong) CBCentralManager *centralManager;

@end

@implementation ORSBluetoothLEScanner

+ (id)sharedBluetoothLEScanner;
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedBluetoothLEScanner = [[self alloc] init];
	});
	
	return sharedBluetoothLEScanner;	
}

- (id)init
{
    self = [super init];
    if (self)
	{
		self.internalDetectedPeripherals = [[NSMutableSet alloc] init];
		self.bluetoothEnabled = NO;
    }
    return self;
}

- (void)scan
{
	[[self mutableSetValueForKey:@"internalDetectedPeripherals"] removeAllObjects];
	
	NSArray *services = @[[CBUUID UUIDWithString:@"0bd51666-e7cb-469b-8e4d-2742f1ba77cc"]];
	[self.centralManager scanForPeripheralsWithServices:services options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @NO}];
	self.scanning = YES;
	
	// Stop scanning after 5 seconds
	[self performSelector:@selector(stopScanning) withObject:nil afterDelay:5.0];
}

- (void)stopScanning
{
	[self.centralManager stopScan];
	self.scanning = NO;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	NSLog(@"%s %d", __PRETTY_FUNCTION__, central.state);
	if (central.state == CBCentralManagerStatePoweredOn) self.bluetoothEnabled = YES;
	if (central.state == CBCentralManagerStatePoweredOff) self.bluetoothEnabled = NO;
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)newPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	NSLog(@"%s %@ %@ %@", __PRETTY_FUNCTION__, newPeripheral, advertisementData, RSSI);
	NSString *UUIDString = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, newPeripheral.UUID));
	NSSet *existingPeripherals = [self.internalDetectedPeripherals objectsPassingTest:^BOOL(CBPeripheral *eachPeripheral, BOOL *stop) {
		NSString *eachUUIDString = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, eachPeripheral.UUID));
		return [eachUUIDString isEqualToString:UUIDString];
	}];
	NSMutableSet *mutableInternalPeripherals = [self mutableSetValueForKey:@"internalDetectedPeripherals"];
	for (CBPeripheral *peripheral in existingPeripherals) { [mutableInternalPeripherals removeObject:peripheral]; }
	[self addInternalDetectedPeripheral:newPeripheral];
}

#pragma mark - Properties

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"detectedPeripherals"])
	{
		keyPaths = [keyPaths setByAddingObject:@"internalDetectedPeripherals"];
	}
	
	return keyPaths;
}

@synthesize internalDetectedPeripherals = _internalDetectedPeripherals;

- (void)setInternalDetectedPeripherals:(NSMutableSet *)pers
{
	if (pers != _internalDetectedPeripherals)
	{
		_internalDetectedPeripherals = [pers mutableCopy];
	}
}

- (void)addInternalDetectedPeripheral:(CBPeripheral *)internalDetectedPeripheral
{
	id internalPers = self.internalDetectedPeripherals;
    [internalPers addObject:internalDetectedPeripheral];
}

- (void)removeInternalDetectedPeripheral:(CBPeripheral *)internalDetectedPeripheral
{
    [self.internalDetectedPeripherals removeObject:internalDetectedPeripheral];
}

- (NSSet *)detectedPeripherals
{
	return [self.internalDetectedPeripherals copy];
}

- (CBCentralManager *)centralManager
{
	if (!_centralManager)
	{
		_centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
	}
	return _centralManager;
}

@end
