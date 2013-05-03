//
//  FormCreationBarTextCell.m
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "FormCreationBarTextCell.h"

@implementation FormCreationBarTextCell

- (id)init
{
    self = [super init];
	if (self)
	{
        [self setCellType:kTextCell];
        [self setField:[FormTextField defaultField]];
        [self setFieldDelegate:self];
	}
	
	return self;
}

+ (id)cellWithIcon:(NSImage*)anIcon
{
    FormCreationBarTextCell *item = [self itemWithTitle:@"TextField" identifier:@"text" icon:anIcon];
    return item;
}

- (NSDictionary *)properties
{
    NSString *placeholder;
    NSString *title = [self title];
    if ([[self field] respondsToSelector:@selector(placeholderString)])
    {
        placeholder = [[self field] performSelector:@selector(placeholderString)];
    }
    if (!placeholder)
        placeholder = @"";
    
    NSString *size;
    NSControlSize controlSize = [[[self field] cell] controlSize];
    switch (controlSize) {
        case NSRegularControlSize:
            size = @"Regular";
            break;
        case NSSmallControlSize:
            size = @"Small";
            break;
        case NSMiniControlSize:
            size = @"Mini";
            break;
        default:
            break;
    }
    
    return [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:title, placeholder, size, nil] forKeys:[NSArray arrayWithObjects:@"name", @"placeholder", @"size", nil]];
}

@end
