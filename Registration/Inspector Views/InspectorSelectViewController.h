//
//  InspectorSelectView.h
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "InspectorViewController.h"

@interface InspectorSelectViewController : InspectorViewController
{
    IBOutlet NSTextField *name;
    IBOutlet NSPopUpButton *size;
    IBOutlet NSScrollView *elements;
}

@end
