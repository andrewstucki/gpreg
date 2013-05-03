//
//  ClientWindow.h
//  Registration
//
//  Created by Andrew Stucki on 4/15/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ClientWindow : NSWindow {
    BOOL fullscreen;
}

- (BOOL) isFullScreen;

@end
