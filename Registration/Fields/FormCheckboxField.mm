//
//  FormCheckboxField.m
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "FormCheckboxField.h"
#import <objc/runtime.h>

@implementation FormCheckboxField

- (id)initWithFrame:(NSRect)frame
{
    NSButtonCell *prototype = [[NSButtonCell alloc] init];
    [prototype setTitle:@"Checkbox"];
    [prototype setButtonType:NSSwitchButton];

    self = [super initWithFrame:frame
                           mode:NSHighlightModeMatrix
                      prototype:(NSCell *)prototype
                   numberOfRows:1
                numberOfColumns:1];

    if (self) {
        [[self cellAtRow:0 column:0] setEnabled:NO];
        [self sizeToCells];
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
    return [[self alloc] initWithFrame:NSMakeRect(20, 20, 125, 125)];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [[self nextResponder] mouseDown:theEvent];
}

- (void)setNumberOfElements:(NSNumber *)numElements
{
    NSUInteger elements = [[self cells] count];
    NSUInteger newElements = [numElements integerValue];
    NSButtonCell *prototype = [[NSButtonCell alloc] init];
    [prototype setTitle:@"Checkbox"];
    [prototype setButtonType:NSSwitchButton];

    while (elements > newElements)
    {
        [self removeRow:elements-1];
        elements--;
    }
    while (elements < newElements)
    {
        [self addRowWithCells:[NSArray arrayWithObject:[prototype copy]]];
        [[self cellAtRow:elements column:0] setEnabled:NO];
        elements++;
    }
    
    [self sizeToCells];
}

- (void)setElementLabel:(NSString *)label forElementWithIndex:(NSNumber *)index
{
    [[self cellAtRow:[index integerValue] column:0] setTitle:label];
}

@end
