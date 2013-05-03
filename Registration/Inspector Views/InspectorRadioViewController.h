//
//  InspectorRadioViewController.h
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "InspectorViewController.h"

@interface InspectorRadioViewController : InspectorViewController
{
    IBOutlet NSTextField *name;
    IBOutlet NSPopUpButton *size;
    IBOutlet NSTextField *numberOfElements;
    
    IBOutlet NSPopUpButton *elementNumber;
    IBOutlet NSTextField *elementLabel;
}

@property NSInteger numberOfElementsValue;

@end
