//
//  ClientController.m
//  Registration
//
//  Created by Andrew Stucki on 4/11/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "ClientController.h"

@implementation ClientController

NSString *const kFormView		= @"FormLayoutView";
NSString *const kConfigView		= @"ClientConfigurationView";

@synthesize window;

@synthesize sidebar;
@synthesize content;
@synthesize connectedText;

@synthesize syncButton;
@synthesize formButton;
@synthesize networkButton;

@synthesize connected;
@synthesize client;

- (id)init
{
    self = [super init];
    if (self)
    {        
        connected = NO;
        client = new RegistrationClient();
    }
    return self;
}

-(void)dealloc
{
    delete client;
}

- (void) awakeFromNib
{
    formViewController = [[FormLayoutViewController alloc] initWithNibName:kFormView bundle:nil];
    configurationViewController = [[ClientConfigurationViewController alloc] initWithNibName:kConfigView bundle:nil parent:self];
    
    ///////////////
    // Setup sidebar with default cell (EDSideBarCell)
	// Buttons top-aligned. Selection animated
	[sidebar setLayoutMode:ECSideBarLayoutTop];
	sidebar.animateSelection =YES;
	sidebar.sidebarDelegate = self;
	NSImage *selImage = [self buildSelectionImage];
	[sidebar setSelectionImage:selImage];
	
    [sidebar addButtonWithTitle:@"Configure" image:[NSImage imageNamed:@"network32.png"]];
    networkButton = [sidebar cellForItem:0];
    
	[sidebar addButtonWithTitle:@"Build Form" image:[NSImage imageNamed:@"form32.png"]];
    formButton = [sidebar cellForItem:1];
	
    [sidebar addButtonWithTitle:@"Sync" image:[NSImage imageNamed:@"sync32.png"]];
    syncButton = [sidebar cellForItem:2];
    
	[sidebar selectButtonAtRow:0];
    
	// Add a bit of noise texture
    sidebar.noiseAlpha=0.04;
    [sidebar setTarget:self withSelector:@selector(showConfiguration) atIndex:0];
    [sidebar setTarget:self withSelector:@selector(showFormBuilder) atIndex:1];

    [formButton setEnabled:NO];
    [syncButton setEnabled:NO];
    ///////////////
    
    defaultWindowFrame = [window frame];
    screenFrame = [[NSScreen mainScreen] frame];
    
    [window setContentBorderThickness:24.0 forEdge:NSMinYEdge];
    [window setAutorecalculatesContentBorderThickness:NO forEdge:NSMinYEdge];
    
    [connectedText setStringValue:@"Not Connected"];
    
    [self showConfiguration];
}

-(NSImage*)buildSelectionImage
{
	// Create the selection image on the fly, instead of loading from a file resource.
	NSInteger imageWidth=12, imageHeight=22;
	NSImage* destImage = [[NSImage alloc] initWithSize:NSMakeSize(imageWidth,imageHeight)];
	[destImage lockFocus];

	// Constructing the path
    NSBezierPath *triangle = [NSBezierPath bezierPath];
	[triangle setLineWidth:1.0];
    [triangle moveToPoint:NSMakePoint(imageWidth+1, 0.0)];
    [triangle lineToPoint:NSMakePoint( 0, imageHeight/2.0)];
    [triangle lineToPoint:NSMakePoint( imageWidth+1, imageHeight)];
    [triangle closePath];
	[[NSColor controlColor] setFill];
	[[NSColor darkGrayColor] setStroke];
	[triangle fill];
	[triangle stroke];
	[destImage unlockFocus];
	return destImage;
}

- (IBAction)clientWindowActivate:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
	[window makeKeyAndOrderFront:self];
}

- (void)autoResizeWindow:(NSWindow *)aWindow toView:(NSView *)view
{
    NSView *oldView;
    BOOL hasSubs = NO;
    if ([[content subviews] count] != 0) {
        hasSubs = YES;
        oldView = [[content subviews] objectAtIndex:0];
    }
    else
        oldView = content;
    
    NSRect oldFrame = [oldView frame];
    NSRect viewFrame = [view frame];
    NSRect newFrame = [aWindow frame];
	newFrame.size.height += (viewFrame.size.height - oldFrame.size.height);
	newFrame.size.width += (viewFrame.size.width - oldFrame.size.width);
	newFrame.origin.y += (oldFrame.size.height - viewFrame.size.height);
	
	//set the frame to newFrame and animate it. (change animate:YES to animate:NO if you don't want this)
	[window setShowsResizeIndicator:YES];
    
    if (hasSubs)
        [oldView removeFromSuperview];
    
	[window setFrame:newFrame display:YES animate:YES];
    [window setMaxSize:newFrame.size];
    [window setMinSize:newFrame.size];
}

- (void)showFormBuilder
{
    BOOL fullscreen = NO;
    if (!fullscreen)
        [self autoResizeWindow:window toView:[formViewController view]];
    [content setSubviews:[NSArray arrayWithObject:[formViewController view]]];
    if (![window isFullScreen] && fullscreen)
    {
        [window setMaxSize:screenFrame.size];
        NSWindowCollectionBehavior behavior = [window collectionBehavior];
        behavior |= NSWindowCollectionBehaviorFullScreenPrimary;
        [window setCollectionBehavior:behavior];
        [window toggleFullScreen:self];
    }
}

- (void)showConfiguration
{
    BOOL fullscreen = NO;
    if (!fullscreen)
        [self autoResizeWindow:window toView:[configurationViewController view]];
    [content setSubviews:[NSArray arrayWithObject:[configurationViewController view]]];
    if ([window isFullScreen] && fullscreen)
    {
        [window setMaxSize:defaultWindowFrame.size];
        [window toggleFullScreen:self];
        NSWindowCollectionBehavior behavior = [window collectionBehavior];
        behavior ^= NSWindowCollectionBehaviorFullScreenPrimary;
        [window setCollectionBehavior:behavior];
    }
}

- (NSApplicationPresentationOptions)window:(NSWindow *)window willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions
{
    // customize our appearance when entering full screen:
    // we don't want the dock to appear but we want the menubar to hide/show automatically
    //
    return (NSApplicationPresentationFullScreen |       // support full screen for this window (required)
            NSApplicationPresentationHideDock |         // completely hide the dock
            NSApplicationPresentationHideMenuBar);  // yes we want the menu bar to show/hide
}

- (void)windowDidEnterFullScreen:(NSNotification *)notification
{

}

//- (void)window:(NSWindow *)window startCustomAnimationToEnterFullScreenWithDuration:(NSTimeInterval)duration
//{
//    NSRect proposedFrame = screenFrame;
//    
//    proposedFrame.origin.x += floor((NSWidth(screenFrame) - NSWidth(proposedFrame))/2);
//    proposedFrame.origin.y += floor((NSHeight(screenFrame) - NSHeight(proposedFrame))/2);
//    
//    // The center frame for each window is used during the 1st half of the fullscreen animation and is
//    // the window at its original size but moved to the center of its eventual full screen frame.
//    NSRect centerWindowFrame = [window frame];
//    centerWindowFrame.origin.x = NSWidth(proposedFrame)/2 - NSWidth(centerWindowFrame)/2;
//    centerWindowFrame.origin.y = NSHeight(proposedFrame)/2 - NSHeight(centerWindowFrame)/2;
//    
//    // Our animation will be broken into two stages.
//    // First, we'll move the window to the center of the primary screen and then we'll enlarge
//    // it its full screen size.
//    //
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//        
//        [context setDuration:duration];
//        [[window animator] setFrame:centerWindowFrame display:YES];
//        
//    } completionHandler:^{
//        
//        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//            
//            [context setDuration:duration/4];
//            [[window animator] setFrame:proposedFrame display:YES];
//            
//        } completionHandler:^{
//            
//        }];
//    }];
//}


@end
