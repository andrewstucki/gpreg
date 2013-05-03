//
//  FormCreationBarLabelCell.m
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "FormCreationBarLabelCell.h"

@implementation FormCreationBarLabelCell

- (id)init
{
    self = [super init];
	if (self)
	{
        [self setCellType:kLabelCell];
        [self setField:[FormLabelField defaultField]];
        [self setFieldDelegate:self];
	}
	
	return self;
}

+ (id)cellWithIcon:(NSImage*)anIcon
{
    FormCreationBarLabelCell *item = [self itemWithTitle:@"Label" identifier:@"label" icon:anIcon];
    return item;
}

- (NSDictionary *)properties
{
    NSString *title = [self title];
    
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
    
    return [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:title, size, nil] forKeys:[NSArray arrayWithObjects:@"name", @"size", nil]];
}

@end
