//
//  FormCreationBarCell.h
//  Registration
//
//  Created by Andrew Stucki on 4/15/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FormFieldDelegate.h"

extern NSString *const kTextCell;
extern NSString *const kRadioCell;
extern NSString *const kCheckboxCell;
extern NSString *const kSelectCell;
extern NSString *const kLabelCell;

@interface FormCreationBarCell : NSObject<FormFieldDelegate>

@property NSString *cellType;

@property (nonatomic) NSString *title;
@property NSString *identifier;
@property NSImage *icon;
@property NSInteger badgeValue;
@property BOOL isCategory;

@property NSControl *field;

@property NSMutableArray *children;
@property id<FormFieldDelegate> delegate;

//Convenience methods
+ (id)itemWithTitle:(NSString*)aTitle identifier:(NSString*)anIdentifier;
+ (id)itemWithTitle:(NSString*)aTitle identifier:(NSString*)anIdentifier icon:(NSImage*)anIcon;

- (BOOL)hasBadge;
- (BOOL)hasChildren;
- (BOOL)hasIcon;
- (void)addChild:(FormCreationBarCell *)child;
- (NSInteger)countOfChildren;

- (void)updateFieldName:(NSNotification *)notification;
- (void)updateFieldSize:(NSNotification *)notification;
- (void)updateFieldPlaceholder:(NSNotification *)notification;
- (void)updateFieldElementNumbers:(NSNotification *)notification;
- (void)updateFieldElementLabel:(NSNotification *)notification;
- (void)updateFieldFrame:(NSNotification *)notification;

- (void)setFieldDelegate:(id)aDelegate;
- (NSDictionary *)properties;

//@property IBOutlet NSButton *button;

@end
