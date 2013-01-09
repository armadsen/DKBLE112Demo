//
//  ORSBluetoothCableReplacementViewController.h
//  DKBLE112 Demo
//
//  Created by Andrew Madsen on 1/8/13.
//  Copyright (c) 2013 Open Reel Software. All rights reserved.
//

#import "ORSBluetoothBoardViewController.h"

@interface ORSBluetoothCableReplacementViewController : ORSBluetoothBoardViewController

- (IBAction)send:(id)sender;

// IBOutlets
@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UITextView *outputTextView;

@end
