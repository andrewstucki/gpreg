//
//  ClientController.h
//  Registration
//
//  Created by Andrew Stucki on 4/11/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

#import "ClientWindow.h"
#import "ClientConfigurationViewController.h"
#import "FormLayoutViewController.h"

#import "EDSideBar.h"

#include "client.h"

@class FormLayoutViewController;
@class ClientConfigurationViewController;

@interface ClientController : NSObject <EDSideBarDelegate>
{
    NSRect defaultWindowFrame;
    NSRect screenFrame;
    
    FormLayoutViewController *formViewController;
    ClientConfigurationViewController *configurationViewController;
    
}

@property IBOutlet ClientWindow *window;
@property IBOutlet NSView *content;
@property IBOutlet EDSideBar *sidebar;
@property IBOutlet NSTextField *connectedText;

@property (readonly) RegistrationClient *client;
@property BOOL connected;

@property NSButtonCell *networkButton;
@property NSButtonCell *formButton;
@property NSButtonCell *syncButton;

- (IBAction)clientWindowActivate:(id)sender;

@end
