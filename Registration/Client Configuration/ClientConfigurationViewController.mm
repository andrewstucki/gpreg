//
//  ClientConfigurationViewController.m
//  Registration
//
//  Created by Andrew Stucki on 4/17/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "ClientConfigurationViewController.h"

@interface ClientConfigurationViewController ()

@end

@implementation ClientConfigurationViewController

@synthesize passwordText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(ClientController *)parentObject
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        parent = parentObject;
    }
    return self;
}

- (IBAction)beginScan:(id)sender
{
    [self disableServerGroup];
    [connectOrDisconnect setEnabled:NO];
    [servers removeAllItems];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [parent client]->Discover(5000);
        
        // 1. Creating a completion indicator
        
        BOOL __block animationHasCompleted = NO;
        
        // 2. Requesting core animation do do some work. Using animator for instance.
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
            [standaloneCheckbox setEnabled:YES];
            [scan setTitle:@"Scan"];
            [self updateServers];
            [self enableServerGroup];
        } completionHandler:^{
            animationHasCompleted = YES;
        }];

        // 3. Doing other stuff...
        
        // 4. Waiting for core animation to complete before exiting
        
        while (animationHasCompleted == NO)
        {
            usleep(10000);
        }
    });
    [scan setTitle:@"Scanning..."];
    [scan setEnabled:NO];
    [standaloneCheckbox setEnabled:NO];
}

- (IBAction)toggleStandalone:(id)sender
{
    if([sender state] == NSOnState)
    {
        if ([parent connected])
            [self connectToServer:self];
        [self disableAll];
        [[parent formButton] setEnabled:YES];
    }
    else
    {
        [self enableServerGroup];
        [[parent formButton] setEnabled:NO];
    }
}


- (IBAction)connectToServer:(id)sender
{
    int response;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSCriticalAlertStyle];
    if ([parent connected])
    {
        [parent setConnected:NO];
        [[parent connectedText] setStringValue:@"Not Connected"];
        [[parent syncButton] setEnabled:NO];
        [self disableFormGroup];
        [self enableServerGroup];
        [connectOrDisconnect setTitle:@"Connect"];
        [parent client]->Disconnect();
    }
    else
    {
        ServerInfo *info = &[parent client]->serverInfo.at([servers indexOfSelectedItem]);
        if (passwordText)
        {
            std::string cpass([passwordText UTF8String]);
            info->password = cpass;
        }
        else
            info->password = "";
        
        [parent setConnected:YES];
        [[parent connectedText] setStringValue:@"Connected"];
        if ([password isEnabled] && info->password.empty()) {
            [alert setMessageText:@"Server requires password."];
            [alert setInformativeText:@"The server requires a password, please make sure you entered one."];
            [alert beginSheetModalForWindow:[parent window]
                              modalDelegate:self
                             didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                                contextInfo:&response];
            return;
        }
        
        [parent client]->Connect(info);
        bool communicationUp = [parent client]->List("andrew");
        if (!communicationUp)
        {
            [alert setMessageText:@"Unable to connect to server."];
            [alert setInformativeText:@"The server rejected the password you entered, please make sure you entered the password correctly."];
            [alert beginSheetModalForWindow:[parent window]
                              modalDelegate:self
                             didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                                contextInfo:&response];
            return;
        }
        
        [self disableServerGroup];
        [scan setEnabled:NO];
        [connectOrDisconnect setTitle:@"Disconnect"];
        [forms removeAllItems];
        [self updateForms];
        [self enableFormGroup];
        [[parent syncButton] setEnabled:YES];
    }
}

- (void) alertDidEnd:(NSAlert *) alert returnCode:(int) returnCode contextInfo:(int *) contextInfo
{
    [self connectToServer:self];
}


- (void)disableServerGroup
{
    [serversLabel setAlphaValue:0.5f];
    [servers setEnabled:NO];
    [passwordLabel setAlphaValue:0.5f];
    [password setEnabled:NO];
}

- (void)enableServerGroup
{
    [scan setEnabled:YES];
    if ([[servers itemArray] count] > 0)
    {
        [serversLabel setAlphaValue:1.0f];
        [servers setEnabled:YES];
        [self enablePasswordIfNeccessary];
        [connectOrDisconnect setEnabled:YES];
    }
}

- (void)disableFormGroup
{
    [forms setEnabled:NO];
    [fullscreenCheckbox setEnabled:NO];
    [startForm setEnabled:NO];
    [refreshForms setEnabled:NO];
    [formsLabel setAlphaValue:0.5f];
}

- (void)enableFormGroup
{
    [refreshForms setEnabled:YES];
    [fullscreenCheckbox setEnabled:YES];
    if ([[forms itemArray] count] > 0)
    {
        [forms setEnabled:YES];
        [startForm setEnabled:YES];
        [formsLabel setAlphaValue:1.0f];
    }
}

- (void)disableAll
{
    [self disableServerGroup];
    [self disableFormGroup];
    [connectOrDisconnect setEnabled:NO];
    [scan setEnabled:NO];
}

- (void)enablePasswordIfNeccessary
{
    if ([parent client]->serverInfo.at([servers indexOfSelectedItem]).flags & PASSWORD_ENABLED) {
        [passwordLabel setAlphaValue:1.0f];
        [password setEnabled:YES];
    }
}

- (void)updateServers
{
    for(std::vector<ServerInfo>::iterator it = [parent client]->serverInfo.begin(); it != [parent client]->serverInfo.end(); ++it)
    {
        [servers addItemWithTitle:[NSString stringWithUTF8String:it->address]];
    }
}

- (void)updateForms
{
    for(std::vector<uint32_t>::iterator it = [parent client]->forms.begin(); it != [parent client]->forms.end(); ++it)
    {
        [forms addItemWithTitle:[NSString stringWithFormat:@"%d", *it]];
    }
}


@end
