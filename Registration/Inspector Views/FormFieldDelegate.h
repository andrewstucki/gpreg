//
//  InspectorFieldViewDelegate.h
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FormFieldDelegate <NSObject>
@optional

- (void)nameChanged:(NSString *)newName;
- (void)frameChanged:(NSRect)newFrame;

- (void)numberOfElementsChanged:(NSInteger)newNumberOfElements;
- (void)elementLabelChanged:(NSString *)newLabel forElementAtIndex:(NSInteger)index;

- (void)placeholderChanged:(NSString *)newPlaceholder;

@end