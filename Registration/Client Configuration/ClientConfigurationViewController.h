//
//  ClientConfigurationViewController.h
//  Registration
//
//  Created by Andrew Stucki on 4/17/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ClientController.h"

@class ClientController;

@interface ClientConfigurationViewController : NSViewController
{
    IBOutlet NSButton *standaloneCheckbox;
    
    IBOutlet NSButton *scan;
    IBOutlet NSTextField *serversLabel;
    IBOutlet NSPopUpButton *servers;
    IBOutlet NSTextField *passwordLabel;
    IBOutlet NSSecureTextField *password;
    IBOutlet NSButton *connectOrDisconnect;
    
    IBOutlet NSButton *refreshForms;
    IBOutlet NSButton *startForm;
    IBOutlet NSTextField *formsLabel;
    IBOutlet NSPopUpButton *forms;
    IBOutlet NSButton *fullscreenCheckbox;

    ClientController *parent;
    
}

@property NSString *passwordText;

- (IBAction)beginScan:(id)sender;
- (IBAction)toggleStandalone:(id)sender;
- (IBAction)connectToServer:(id)sender;
- (void)updateServers;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(ClientController *)parentObject;

@end
