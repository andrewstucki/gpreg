//
//  InspectorTextViewController.h
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "InspectorViewController.h"

@interface InspectorTextViewController : InspectorViewController
{
    IBOutlet NSTextField *name;
    IBOutlet NSTextField *placeholder;
    IBOutlet NSPopUpButton *size;
}

@end
