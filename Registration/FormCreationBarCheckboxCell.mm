//
//  FormCreationBarCheckboxCell.m
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "FormCreationBarCheckboxCell.h"

@implementation FormCreationBarCheckboxCell

- (id)init
{
    self = [super init];
	if (self)
	{
        [self setCellType:kCheckboxCell];
        [self setField:[FormCheckboxField defaultField]];
        [self setFieldDelegate:self];
	}
	
	return self;
}

+ (id)cellWithIcon:(NSImage*)anIcon
{
    FormCreationBarCheckboxCell *item = [self itemWithTitle:@"CheckboxField" identifier:@"checkbox" icon:anIcon];
    return item;
}

- (NSDictionary *)properties
{
    NSString *title = [self title];
    
    NSString *size = @"Regular";
    __block NSMutableArray *cellLabels = [NSMutableArray array];
    [[(FormCheckboxField *)[self field] cells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [cellLabels addObject:[obj title]];
    }];
    
    //    NSInteger height = [[self field] frame].size.height;
    //    switch (height) {
    //        case kTextFieldDefaultHeight:
    //            size = @"Regular";
    //            break;
    //        case kTextFieldSmallHeight:
    //            size = @"Small";
    //            break;
    //        case kTextFieldMiniHeight:
    //            size = @"Mini";
    //            break;
    //        default:
    //            break;
    //    }
    
    return [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:title, size, cellLabels, nil] forKeys:[NSArray arrayWithObjects:@"name", @"size", @"elements", nil]];
}


@end
