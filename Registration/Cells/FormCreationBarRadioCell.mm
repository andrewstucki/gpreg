//
//  FormCreationBarRadioCell.m
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "FormCreationBarRadioCell.h"

@implementation FormCreationBarRadioCell

- (id)init
{
    self = [super init];
	if (self)
	{
        [self setCellType:kRadioCell];
        [self setField:[FormRadioField defaultField]];
        [self setFieldDelegate:self];
	}
	
	return self;
}

+ (id)cellWithIcon:(NSImage*)anIcon
{
    FormCreationBarRadioCell *item = [self itemWithTitle:@"RadioButtonField" identifier:@"radio" icon:anIcon];
    return item;
}

- (NSDictionary *)properties
{
    NSString *title = [self title];
    
    NSString *size = @"Regular";
    __block NSMutableArray *cellLabels = [NSMutableArray array];
    [[(FormRadioField *)[self field] cells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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
