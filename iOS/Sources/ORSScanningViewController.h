//
//  ORSViewController.h
//  DKBLE112 Demo
//
//  Created by Andrew Madsen on 1/7/13.
//  Copyright (c) 2013 Open Reel Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ORSScanningViewController : UIViewController <CBCentralManagerDelegate>

- (IBAction)scan:(id)sender;

// Properties

// IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;

@end
