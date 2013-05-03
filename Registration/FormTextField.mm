//
//  FormTextField.m
//  Registration
//
//  Created by Andrew Stucki on 4/16/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "FormTextField.h"
#import "FormTextFieldCell.h"
#import <objc/runtime.h>

enum
{
    kTextFieldDefaultHeight = 22,
    kTextFieldSmallHeight = 19,
    kTextFieldMiniHeight = 16,
};

@implementation FormTextField

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setEnabled:NO];
        // Initialization code here.
    }
    
    return self;
}

+ (id)defaultField
{
    return [[self alloc] initWithFrame:NSMakeRect(10, 10, 96, 22)];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [NSGraphicsContext saveGraphicsState];
    [super drawRect:dirtyRect];
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawField:(NSRect)dirtyRect
{
    [super setNeedsDisplay:YES];
}

- (void)setPlaceholderString:(NSString *)aString
{
    [[self cell] setPlaceholderString:aString];
}

- (NSString *)placeholderString
{
    return [[self cell] placeholderString];
}

- (void)setSize:(NSNumber *)size
{
    NSInteger systemSize = [size integerValue];
    NSInteger currentSize = [[self cell] controlSize];
    NSInteger frameHeight = [self frame].size.height;
    
    BOOL isDefaultSize = (currentSize == NSRegularControlSize) && (frameHeight == kTextFieldDefaultHeight);
    isDefaultSize |= (currentSize == NSSmallControlSize) && (frameHeight == kTextFieldSmallHeight);
    isDefaultSize |= (currentSize == NSMiniControlSize) && (frameHeight == kTextFieldMiniHeight);

    [[self cell] setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:systemSize]]];
    [[self cell] setControlSize:systemSize];
    
    if (isDefaultSize) {
        NSRect newFrame = [self frame];
        switch (systemSize) {
            case NSRegularControlSize:
                newFrame.size.height = kTextFieldDefaultHeight;
                break;
            case NSSmallControlSize:
                newFrame.size.height = kTextFieldSmallHeight;
                break;
            case NSMiniControlSize:
                newFrame.size.height = kTextFieldMiniHeight;
                break;
            default:
                break;
        }
        [self setFrame:newFrame];
    }
}

//+ (void)load
//{
//    Method original, swizzled;
//    
//    original = class_getInstanceMethod(self, @selector(drawRect:));
//    swizzled = class_getInstanceMethod(self, @selector(drawField:));
//    method_exchangeImplementations(original, swizzled);
//}

+(void)load
{
    [self setCellClass:[FormTextFieldCell class]];
}

@end
