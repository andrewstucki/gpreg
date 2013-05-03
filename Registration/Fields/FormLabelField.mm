//
//  FormLabelField.m
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "FormLabelField.h"
#import <objc/runtime.h>

enum
{
    kLabelFieldDefaultHeight = 22,
    kLabelFieldSmallHeight = 19,
    kLabelFieldMiniHeight = 16,
};

@implementation FormLabelField

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setStringValue:@"Label"];
        [self setBezeled:NO];
        [self setDrawsBackground:NO];
        [self setEditable:NO];
        [self setSelectable:NO];
        [self setAlphaValue:0.5f];
        [self sizeToFit];
    }
    
    return self;
}

//- (void)drawRect:(NSRect)dirtyRect
//{
//    // Drawing code here.
//}

+ (id)defaultField
{
    return [[self alloc] initWithFrame:NSMakeRect(10, 10, 200, 17)];
}

- (void)setFieldStringValue:(NSString *)aString
{
    [self setStringValue:aString];
    [self sizeToFit];
}

- (void)setSize:(NSNumber *)size
{
    NSInteger systemSize = [size integerValue];
    
    [[self cell] setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:systemSize]]];
    [[self cell] setControlSize:systemSize];
    
    [self sizeToFit];
}

@end
