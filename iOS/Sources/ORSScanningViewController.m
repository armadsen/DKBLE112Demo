//
//  ORSViewController.m
//  DKBLE112 Demo
//
//  Created by Andrew Madsen on 1/7/13.
//  Copyright (c) 2013 Open Reel Software. All rights reserved.
//

#import "ORSScanningViewController.h"
#import "ORSBluetoothBoardViewController.h"
#import "ORSBluetoothBoardSupport.h"

@interface ORSScanningViewController ()

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *connectingPeripheral;
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;
@property (nonatomic, strong) NSTimer *scanStopTimer;

@end

@implementation ORSScanningViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.activityIndicator.hidesWhenStopped = YES;
	
	self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
	
	self.statusLabel.text = @"Tap scan to begin";
}

- (void)dealloc
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// Reset connections
	if (self.connectingPeripheral) [self.centralManager cancelPeripheralConnection:self.connectingPeripheral];
	self.connectingPeripheral = nil;
	
	if (self.connectedPeripheral) [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
	self.connectedPeripheral = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	UIViewController *destination = [segue destinationViewController];
	if ([destination isKindOfClass:[ORSBluetoothBoardViewController class]])
	{
		[(ORSBluetoothBoardViewController *)destination setBluetoothPeripheral:self.connectedPeripheral];
	}
}

#pragma mark - Public Methods

- (IBAction)scan:(id)sender
{
	// First see if the central manager has already found our desired peripheral previously
	[self.centralManager retrievePeripherals:@[ORSBluetoothBoardPeripheralUUIDString]];
	[self.centralManager retrieveConnectedPeripherals];
	
	NSArray *services = @[[CBUUID UUIDWithString:ORSBluetoothBoardCableReplacementServiceUUIDString]];
	[self.centralManager scanForPeripheralsWithServices:services options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
	[self.activityIndicator startAnimating];
	self.statusLabel.text = @"Scanning...";
	
	// Stop scanning after 5 seconds
	self.scanStopTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(stopScanning:) userInfo:nil repeats:NO];
}

#pragma mark - Private

- (void)stopScanning:(NSTimer *)timerOrNil
{
	self.scanStopTimer = nil;
	[self.centralManager stopScan];
	[self.activityIndicator stopAnimating];
	self.statusLabel.text = @"No devices found. Please make sure the Bluetooth board is powered and nearby.";
}

- (void)connectToBluetoothBoard:(CBPeripheral *)peripheral
{
	[self stopScanning:nil];
	self.statusLabel.text = @"Found Bluetooth device. Trying to connect...";
	
	if (peripheral == self.connectedPeripheral && peripheral.isConnected) return [self performSegueWithIdentifier:@"PushBluetoothBoardViewSegue" sender:nil]; // Already connected
	if (self.connectingPeripheral && self.connectingPeripheral != peripheral) [self.centralManager cancelPeripheralConnection:self.connectingPeripheral]; // Already connecting to a different device
	
	self.connectingPeripheral = peripheral;
	[self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey : @YES}];
}

- (BOOL)peripheralIsBluetoothBoard:(CBPeripheral *)peripheral
{
	NSString *peripheralUUID = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, peripheral.UUID));
	return [peripheralUUID caseInsensitiveCompare:ORSBluetoothBoardPeripheralUUIDString] == NSOrderedSame;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	NSLog(@"%s %d", __PRETTY_FUNCTION__, central.state);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	NSLog(@"%s %@ %@ %@", __PRETTY_FUNCTION__, peripheral, advertisementData, RSSI);
	if (![self peripheralIsBluetoothBoard:peripheral]) return;
	
	// Found desired device
	[self connectToBluetoothBoard:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
	NSLog(@"%s %@", __PRETTY_FUNCTION__, peripherals);
	
	NSIndexSet *matchingPeripherals = [peripherals indexesOfObjectsPassingTest:^BOOL(CBPeripheral *peripheral, NSUInteger idx, BOOL *stop) {
		return [self peripheralIsBluetoothBoard:peripheral];
	}];
	if (![matchingPeripherals count]) return;
	
	CBPeripheral *peripheral = [[peripherals objectsAtIndexes:matchingPeripherals] lastObject];
	[self connectToBluetoothBoard:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
	NSLog(@"%s %@", __PRETTY_FUNCTION__, peripherals);
	
	NSIndexSet *matchingPeripherals = [peripherals indexesOfObjectsPassingTest:^BOOL(CBPeripheral *peripheral, NSUInteger idx, BOOL *stop) {
		return [self peripheralIsBluetoothBoard:peripheral];
	}];
	if (![matchingPeripherals count]) return;
	
	CBPeripheral *peripheral = [[peripherals objectsAtIndexes:matchingPeripherals] lastObject];
	[self connectToBluetoothBoard:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	self.connectedPeripheral = peripheral;
	if (peripheral == self.connectingPeripheral) self.connectingPeripheral = nil;
	[self performSegueWithIdentifier:@"PushBluetoothBoardViewSegue" sender:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	NSLog(@"Unable to connect to Bluetooth peripheral %@: %@", peripheral, error);
	self.statusLabel.text = [NSString stringWithFormat:@"Error connecting: %@", error];
	self.connectingPeripheral = nil;
	self.connectedPeripheral = nil;
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, peripheral, error);
	if (peripheral == self.connectedPeripheral) self.connectedPeripheral = nil;
}

#pragma mark - Properties

- (void)setScanStopTimer:(NSTimer *)timer
{
	if (timer != _scanStopTimer)
	{
		[_scanStopTimer invalidate];
		_scanStopTimer = timer;
	}
}

@end
