//
//  AppDelegate.h
//  Registration
//
//  Created by Andrew Stucki on 4/10/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ClientController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
@private
	IBOutlet ClientController *clientController;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)chooseMode:(id)sender;

@end
