//
//  ORSBluetoothAccelerometerViewController.h
//  DKBLE112 Demo
//
//  Created by Andrew Madsen on 1/8/13.
//  Copyright (c) 2013 Open Reel Software. All rights reserved.
//

#import "ORSBluetoothBoardViewController.h"

@interface ORSBluetoothAccelerometerViewController : ORSBluetoothBoardViewController

@property (weak, nonatomic) IBOutlet UILabel *xValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *yValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *zValueLabel;

@end
