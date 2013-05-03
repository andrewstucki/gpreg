//
//  FormRadioField.m
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "FormRadioField.h"
#import <objc/runtime.h>

@implementation FormRadioField

- (id)initWithFrame:(NSRect)frame
{
    NSButtonCell *prototype = [[NSButtonCell alloc] init];
    [prototype setTitle:@"Radio"];
    [prototype setButtonType:NSRadioButton];
    
    self = [super initWithFrame:frame
                           mode:NSRadioModeMatrix
                      prototype:(NSCell *)prototype
                   numberOfRows:2
                numberOfColumns:1];
    
    if (self) {
        [[self cellAtRow:0 column:0] setState:NSOffState];
        [[self cellAtRow:0 column:0] setEnabled:NO];
        [[self cellAtRow:1 column:0] setEnabled:NO];
        [self setEnabled:NO];
        [self sizeToCells];

        // Initialization code here.
    }
    
    return self;
}

+ (id)defaultField
{
    return [[self alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
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
    [prototype setTitle:@"Radio"];
    [prototype setButtonType:NSRadioButton];
    
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
