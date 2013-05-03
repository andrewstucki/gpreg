//
//  FormCreationBarCell.m
//  Registration
//
//  Created by Andrew Stucki on 4/15/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "FormCreationBarCell.h"
#import "NSControl+FormField.h"
#import <objc/runtime.h>

NSString *const kTextCell           = @"FormCreationBarTextCell";
NSString *const kRadioCell          = @"FormCreationBarRadioCell";
NSString *const kCheckboxCell       = @"FormCreationBarCheckboxCell";
NSString *const kSelectCell         = @"FormCreationBarSelectCell";
NSString *const kLabelCell          = @"FormCreationBarLabelCell";

@implementation FormCreationBarCell

@synthesize cellType;
@synthesize title;
@synthesize identifier;
@synthesize icon;
@synthesize isCategory;
@synthesize badgeValue;
@synthesize children;
@synthesize field;
@synthesize delegate;

#pragma mark -
#pragma mark Init/Dealloc/Finalize

- (id)init
{
	if(self=[super init])
	{
		badgeValue = -1;	//We don't want a badge value by default
        isCategory = NO;
	}
	
	return self;
}


+ (id)itemWithTitle:(NSString*)aTitle identifier:(NSString*)anIdentifier
{
	return [self itemWithTitle:aTitle identifier:anIdentifier icon:nil];
}


+ (id)itemWithTitle:(NSString*)aTitle identifier:(NSString*)anIdentifier icon:(NSImage*)anIcon
{
	id item = [[self alloc] init];
	
	[item setTitle:aTitle];
	[item setIdentifier:anIdentifier];
	[item setIcon:anIcon];
	
	return item;
}

- (void)finalize
{
	title = nil;
	identifier = nil;
	icon = nil;
	children = nil;
    cellType = nil;
	
	[super finalize];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return delegate;
}

#pragma mark -
#pragma mark Custom Accessors

- (BOOL)hasBadge
{
	return badgeValue!=-1;
}

- (BOOL)hasChildren
{
	return [children count]>0;
}

- (BOOL)hasIcon
{
	return icon!=nil;
}

- (void)addChild:(FormCreationBarCell *)child
{
    if (!children)
        children = [[NSMutableArray alloc] init];
    [children addObject:child];
}

- (NSInteger)countOfChildren
{
    return [children count];
}

- (void)updateFieldName:(NSNotification *)notification
{
    NSString *name = [[notification userInfo] objectForKey:@"name"];
    [self setTitle:name];
    if ([field respondsToSelector:@selector(setFieldStringValue:)]) {
        [field performSelector:@selector(setFieldStringValue:) withObject:name];
    }
}

- (void)updateFieldSize:(NSNotification *)notification
{
    NSString *size = [[notification userInfo] objectForKey:@"size"];
    if ([field respondsToSelector:@selector(setSize:)]) {
        NSInteger controlSize;
        if ([size isEqualToString:@"Regular"])
        {
            controlSize = NSRegularControlSize;
        }
        else if ([size isEqualToString:@"Small"])
        {
            controlSize = NSSmallControlSize;
        }
        else if ([size isEqualToString:@"Mini"])
        {
            controlSize = NSMiniControlSize;
        }
        
        [field performSelector:@selector(setSize:) withObject:[NSNumber numberWithInteger:controlSize]];
    }
}

- (void)updateFieldPlaceholder:(NSNotification *)notification
{
    NSString *placeholder = [[notification userInfo] objectForKey:@"placeholder"];
    if ([field respondsToSelector:@selector(setPlaceholderString:)]) {
        [field performSelector:@selector(setPlaceholderString:) withObject:placeholder];
    }
}

- (void)updateFieldElementNumbers:(NSNotification *)notification
{
    NSNumber *newNumber = [[notification userInfo] objectForKey:@"numberOfElements"];
    if ([field respondsToSelector:@selector(setNumberOfElements:)]) {
        [field performSelector:@selector(setNumberOfElements:) withObject:newNumber];
    }
}

- (void)updateFieldElementLabel:(NSNotification *)notification
{
    NSNumber *elementNumber = [[notification userInfo] objectForKey:@"elementNumber"];
    NSString *newLabel = [[notification userInfo] objectForKey:@"elementLabel"];
    if ([field respondsToSelector:@selector(setElementLabel:forElementWithIndex:)])
    {
        [field performSelector:@selector(setElementLabel:forElementWithIndex:) withObject:newLabel withObject:elementNumber];
    }
}

- (void)updateFieldFrame:(NSNotification *)notification
{
    NSString *frameString = [[notification userInfo] objectForKey:@"frameString"];
    NSRect newFrame = NSRectFromString(frameString);
    [field setFrame:newFrame];
}

- (void)setFieldDelegate:(id)aDelegate
{
    [field setFieldDelegate:aDelegate];
}

- (void)setTitle:(NSString *)aTitle
{
    title = aTitle;
    if ([[self delegate] respondsToSelector:@selector(nameChanged:)])
    {
        [[self delegate] nameChanged:title];
    }
    if ([field respondsToSelector:@selector(setFieldStringValue:)]) {
        [field performSelector:@selector(setFieldStringValue:) withObject:title];
    }
}

- (NSDictionary *)properties
{
    return [NSDictionary dictionary];
}

#pragma mark -
#pragma mark Custom Accessors

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p | identifier = %@ | title = %@ >", [self class], self, self.identifier, self.title];
}

@end