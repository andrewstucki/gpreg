//
//  ClientWindow.m
//  Registration
//
//  Created by Andrew Stucki on 4/15/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "ClientWindow.h"

@implementation ClientWindow

- (id)init
{
    self = [super init];
    if (self)
    {
        fullscreen = NO;
    }
    return self;
}

- (void)keyDown: (NSEvent *) event {
    if ([event keyCode] == 53) {
        NSLog(@"Esc. pressed");
    }
}

- (void)toggleFullScreen:(id)sender
{
    fullscreen = !fullscreen;
    [super toggleFullScreen:sender];
}

- (BOOL) isFullScreen
{
    return fullscreen;
}

@end
