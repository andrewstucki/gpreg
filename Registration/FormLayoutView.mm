//
//  FormLayoutView.m
//  Registration
//
//  Created by Andrew Stucki on 4/16/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "FormLayoutView.h"

@implementation FormLayoutView

@synthesize backgroundView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] set];
    
    // Fill the entire view with the image.
    [NSBezierPath fillRect:[self bounds]];
}

@end
