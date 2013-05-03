//
//  AppDelegate.mm
//  Registration
//
//  Created by Andrew Stucki on 4/10/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction)chooseMode:(id)sender
{
    [window orderOut:self];
    [clientController clientWindowActivate:self];
}

@end
