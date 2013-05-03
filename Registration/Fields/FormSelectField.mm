//
//  FormSelectField.m
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "FormSelectField.h"

enum
{
    kSelectFieldDefaultHeight = 26,
    kSelectFieldSmallHeight = 22,
    kSelectFieldMiniHeight = 15,
};

@implementation FormSelectField

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setEnabled:NO];
        // Initialization code here.
    }
    
    return self;
}

//- (void)drawRect:(NSRect)dirtyRect
//{
//    // Drawing code here.
//}

+ (id)defaultField
{
    return [[self alloc] initWithFrame:NSMakeRect(10, 10, 96, 26)];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [[self nextResponder] mouseDown:theEvent];
}

- (void)setSize:(NSNumber *)size
{
    NSInteger systemSize = [size integerValue];
    NSInteger currentSize = [[self cell] controlSize];
    NSInteger frameHeight = [self frame].size.height;
    
    BOOL isDefaultSize = (currentSize == NSRegularControlSize) && (frameHeight == kSelectFieldDefaultHeight);
    isDefaultSize |= (currentSize == NSSmallControlSize) && (frameHeight == kSelectFieldSmallHeight);
    isDefaultSize |= (currentSize == NSMiniControlSize) && (frameHeight == kSelectFieldMiniHeight);
    
    [[self cell] setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:systemSize]]];
    [[self cell] setControlSize:systemSize];
    
    if (isDefaultSize) {
        NSRect newFrame = [self frame];
        switch (systemSize) {
            case NSRegularControlSize:
                newFrame.size.height = kSelectFieldDefaultHeight;
                break;
            case NSSmallControlSize:
                newFrame.size.height = kSelectFieldSmallHeight;
                break;
            case NSMiniControlSize:
                newFrame.size.height = kSelectFieldMiniHeight;
                break;
            default:
                break;
        }
        [self setFrame:newFrame];
    }
}

@end
