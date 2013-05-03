//
//  FormCreationBarDelegate.mm
//  Registration
//
//  Created by Andrew Stucki on 4/15/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "FormLayoutViewController.h"

#import "FormCreationBarCell.h"

#import <objc/runtime.h>

#include <vector>
#include <algorithm>
#include <functional>

inline bool checkIndexSetContains(NSUInteger index, NSIndexSet *set)
{
    return [set containsIndex:index];
}

@interface FormLayoutViewController () {
    CNSplitViewToolbar *toolbar;
    BOOL useAnimations;
}
@end

@implementation FormLayoutViewController

NSString *const kAlignmentView		= @"InspectorAlignmentView";
NSString *const kAppearanceView		= @"InspectorAppearanceView";
NSString *const kAttributesView		= @"InspectorAttributesView";
NSString *const kCheckboxView       = @"InspectorCheckboxView";
NSString *const kLabelView          = @"InspectorLabelView";
NSString *const kLayoutView         = @"InspectorLayoutView";
NSString *const kRadioView          = @"InspectorRadioView";
NSString *const kSelectView         = @"InspectorSelectView";
NSString *const kTextView           = @"InspectorTextView";

enum
{
    kObjAlignLeft = 0,
    kObjAlignHorizMid,
    kObjAlignRight,
    kObjAlignTop,
    kObjAlignVertMid,
    kObjAlignBot
};

enum
{
    kTextField = 0,
    kRadioField,
    kCheckbox,
    kSelect,
    kLabel
};

#pragma mark -
#pragma mark Init/Dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib
{
    alignmentController = [[InspectorAlignmentViewController alloc] initWithNibName:kAlignmentView bundle:nil];
    appearanceController = [[InspectorAppearanceViewController alloc] initWithNibName:kAppearanceView bundle:nil];
    attributesController = [[InspectorAttributesViewController alloc] initWithNibName:kAttributesView bundle:nil];
    layoutController = [[InspectorLayoutViewController alloc] initWithNibName:kLayoutView bundle:nil];
    
    checkboxController = [[InspectorCheckboxViewController alloc] initWithNibName:kCheckboxView bundle:nil];
    labelController = [[InspectorLabelViewController alloc] initWithNibName:kLabelView bundle:nil];
    layoutController = [[InspectorLayoutViewController alloc] initWithNibName:kLayoutView bundle:nil];
    radioController = [[InspectorRadioViewController alloc] initWithNibName:kRadioView bundle:nil];
    selectController = [[InspectorSelectViewController alloc] initWithNibName:kSelectView bundle:nil];
    textController = [[InspectorTextViewController alloc] initWithNibName:kTextView bundle:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fieldChanged:) name:FormFieldNameChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fieldChanged:) name:FormFieldSizeChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fieldChanged:) name:FormFieldPlaceholderChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fieldChanged:) name:FormFieldNumberOfElementsChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fieldChanged:) name:FormFieldElementLabelChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fieldChanged:) name:FormFieldFrameChangeNotification object:nil];

    [self initSidebar];
    [self fixViewSizes];
}

- (void)initSidebar
{
    creationBarItems = [[NSMutableArray alloc] init];
	
    //Set up the "Form Settings" parent item and children
	FormCreationBarCell *settingsItem = [FormCreationBarCell itemWithTitle:@"Form Settings" identifier:@"settings"];
	
    FormCreationBarCell *attributesItem = [FormCreationBarCell itemWithTitle:@"Attributes" identifier:@"attributes"];
    [attributesItem setIcon:[NSImage imageNamed:@"network.png"]];
    
	FormCreationBarCell *appearanceItem = [FormCreationBarCell itemWithTitle:@"Appearance" identifier:@"appearance"];
    [appearanceItem setIcon:[NSImage imageNamed:@"network.png"]];
    
	[settingsItem setChildren:[NSArray arrayWithObjects:attributesItem, appearanceItem, nil]];
	
	//Set up the "Form Elements" parent item and children
	FormCreationBarCell *elementsItem = [FormCreationBarCell itemWithTitle:@"Form Elements" identifier:@"elements"];
    
    textFields = [FormCreationBarCell itemWithTitle:@"Text Fields" identifier:@"textfields"];
    [textFields setIcon:[NSImage imageNamed:@"network.png"]];
    [textFields setIsCategory:YES];
    
    radioFields = [FormCreationBarCell itemWithTitle:@"Radio Button Fields" identifier:@"radiofields"];
    [radioFields setIcon:[NSImage imageNamed:@"network.png"]];
    [radioFields setIsCategory:YES];
    
    checkBoxFields = [FormCreationBarCell itemWithTitle:@"Check Box Fields" identifier:@"checkboxes"];
    [checkBoxFields setIcon:[NSImage imageNamed:@"network.png"]];
    [checkBoxFields setIsCategory:YES];
    
    selectFields = [FormCreationBarCell itemWithTitle:@"Select Fields" identifier:@"selectfields"];
    [selectFields setIcon:[NSImage imageNamed:@"network.png"]];
    [selectFields setIsCategory:YES];
    
    labels = [FormCreationBarCell itemWithTitle:@"Labels" identifier:@"labels"];
    [labels setIcon:[NSImage imageNamed:@"network.png"]];
    [labels setIsCategory:YES];
    
    [elementsItem setChildren:[NSArray arrayWithObjects:textFields, radioFields, checkBoxFields, selectFields, labels, nil]];
    
	[creationBarItems addObject:settingsItem];
	[creationBarItems addObject:elementsItem];
	
    [sourceList setFloatsGroupRows:NO];
	[sourceList reloadData];
    
    //////////////////////////////
    
    useAnimations = NO;
    toolbar = [[CNSplitViewToolbar alloc] init];
    
    CNSplitViewToolbarButton *addButton = [[CNSplitViewToolbarButton alloc] init];
    [addButton setTitle:@"+"];
    [addButton setKeyEquivalent:@"n"];
    [addButton setKeyEquivalentModifierMask:NSCommandKeyMask];
    [addButton setImagePosition:NSNoImage];
    [addButton setTarget:self];
    [addButton setAction:@selector(addField:)];
    
    popupButton = [[NSPopUpButton alloc] init];
    [popupButton setToolbarItemWidth:120];
    [popupButton addItemsWithTitles:@[ @"Text Field", @"Radio Button Field", @"Checkbox Field", @"Select Field", @"Label" ]];
    [[popupButton cell] setControlSize:NSSmallControlSize];
    
    [toolbar addItem:addButton align:CNSplitViewToolbarItemAlignLeft];
    [toolbar addItem:popupButton align:CNSplitViewToolbarItemAlignLeft];
    
    [splitView attachToolbar:toolbar toSubViewAtIndex:0 onEdge:CNSplitViewToolbarEdgeBottom];
    [splitView showToolbarAnimated:useAnimations];

}

- (void)fixViewSizes
{
    NSView *leftView = [[splitView subviews] objectAtIndex:0];
    NSView *midView = [[splitView subviews] objectAtIndex:1];
    NSView *rightView = [[splitView subviews] objectAtIndex:2];
    float dividerThickness = [splitView dividerThickness];

    NSRect leftFrame = [leftView frame];
    NSRect midFrame = [midView frame];
    NSRect rightFrame = [rightView frame];
    
    leftFrame.size.width = 200.0f;
    rightFrame.size.width = 225.0f;

    midFrame.origin.x = leftFrame.size.width + dividerThickness;
    rightFrame.origin.x = leftFrame.size.width + midFrame.size.width + (2*dividerThickness);
    
    [leftView setFrame:leftFrame];
    [midView setFrame:midFrame];
    [rightView setFrame:rightFrame];
}

- (IBAction)addField:(id)sender
{
    NSInteger type = [popupButton indexOfSelectedItem];
    NSString *klass, *imageName;
    FormCreationBarCell *parent;
    InspectorViewController *fieldDelegate;
    
    switch (type) {
        case kTextField:
            klass = kTextCell;
            parent = textFields;
            imageName = @"network.png";
            fieldDelegate = textController;
            break;
        case kRadioField:
            klass = kRadioCell;
            parent = radioFields;
            imageName = @"network.png";
            fieldDelegate = radioController;
            break;
        case kCheckbox:
            klass = kCheckboxCell;
            parent = checkBoxFields;
            imageName = @"network.png";
            fieldDelegate = checkboxController;
            break;
        case kSelect:
            klass = kSelectCell;
            parent = selectFields;
            imageName = @"network.png";
            fieldDelegate = selectController;
            break;
        case kLabel:
            klass = kLabelCell;
            parent = labels;
            imageName = @"network.png";
            fieldDelegate = labelController;
            break;
        default:
            break;
    }
    id newField = [NSClassFromString(klass) cellWithIcon:[NSImage imageNamed:imageName]];
    [newField setDelegate:fieldDelegate];
    [parent addChild:newField];
    [parent setBadgeValue:[parent countOfChildren]];
    [sourceList reloadData];
    [sourceList expandItem:parent];
    [grid addSubview:[newField field]];
}

- (void)removeFromSidebar:(id)item
{
    
}

- (void)fieldChanged:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:FormFieldNameChangeNotification])
        [sourceList reloadData];
}

#pragma mark -
#pragma mark Source List Data Source Methods

- (NSUInteger)sourceList:(PXSourceList*)sourceList numberOfChildrenOfItem:(id)item
{
	//Works the same way as the NSOutlineView data source: `nil` means a parent item
	if(item==nil) {
		return [creationBarItems count];
	}
	else {
		return [[item children] count];
	}
}


- (id)sourceList:(PXSourceList*)aSourceList child:(NSUInteger)index ofItem:(id)item
{
	//Works the same way as the NSOutlineView data source: `nil` means a parent item
	if(item==nil) {
		return [creationBarItems objectAtIndex:index];
	}
	else {
		return [[item children] objectAtIndex:index];
	}
}


- (id)sourceList:(PXSourceList*)aSourceList objectValueForItem:(id)item
{
	return [item title];
}


- (void)sourceList:(PXSourceList*)aSourceList setObjectValue:(id)object forItem:(id)item
{
	[item setTitle:object];
}


- (BOOL)sourceList:(PXSourceList*)aSourceList isItemExpandable:(id)item
{
	return [item hasChildren];
}


- (BOOL)sourceList:(PXSourceList*)aSourceList itemHasBadge:(id)item
{
	return [item hasBadge];
}


- (NSInteger)sourceList:(PXSourceList*)aSourceList badgeValueForItem:(id)item
{
	return [item badgeValue];
}


- (BOOL)sourceList:(PXSourceList*)aSourceList itemHasIcon:(id)item
{
	return [item hasIcon];
}


- (NSImage*)sourceList:(PXSourceList*)aSourceList iconForItem:(id)item
{
	return [item icon];
}

- (NSMenu*)sourceList:(PXSourceList*)aSourceList menuForEvent:(NSEvent*)theEvent item:(id)item
{
	if ([theEvent type] == NSRightMouseDown || ([theEvent type] == NSLeftMouseDown && ([theEvent modifierFlags] & NSControlKeyMask) == NSControlKeyMask)) {
		NSMenu * m = [[NSMenu alloc] init];
		if (item != nil) {
			[m addItemWithTitle:[item title] action:nil keyEquivalent:@""];
		} else {
			[m addItemWithTitle:@"clicked outside" action:nil keyEquivalent:@""];
		}
		return m;
	}
	return nil;
}

#pragma mark -
#pragma mark Source List Delegate Methods

- (BOOL)sourceList:(PXSourceList*)aSourceList isGroupAlwaysExpanded:(id)group
{
	if([[group identifier] isEqualToString:@"elements"])
		return YES;
	return NO;
}

- (NSUInteger)childrenTotal:(id)item
{
    __block NSUInteger count;
    NSArray *children;
    if (item == nil)
        children = creationBarItems;
    else
        children = [item children];

    count = [children count];
    [children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        count += [self childrenTotal:obj];
    }];

    return count;
}

- (void)sourceListSelectionDidChange:(NSNotification *)notification
{
    [inspectorContainer removeAllInspectorViews];
    NSIndexSet *selectedIndexes = [sourceList selectedRowIndexes];
    
    NSUInteger total = [self childrenTotal:nil];
    
    std::vector<NSUInteger> unselectedItems;
    for (NSUInteger i=0; i < total; i++) {
        unselectedItems.push_back(i);
    }
    
    unselectedItems.erase(std::remove_if(unselectedItems.begin(), unselectedItems.end(), std::bind2nd(std::ptr_fun(checkIndexSetContains),selectedIndexes)));
    
    for (std::vector<NSUInteger>::iterator it = unselectedItems.begin(); it != unselectedItems.end(); ++it) {
        [[NSNotificationCenter defaultCenter] removeObserver:[sourceList itemAtRow:*it]];
    }
    
    if ([selectedIndexes count] > 1)
    {
        [inspectorContainer addInspectorView:[alignmentController inspectorView] expanded:YES];
    }
    else
    {
        id field = [sourceList itemAtRow:[selectedIndexes firstIndex]];
        NSString *identifier = [field identifier];
        if ([identifier isEqualToString:@"attributes"])
        {
            [inspectorContainer addInspectorView:[attributesController inspectorView] expanded:YES];
        }
        else if ([identifier isEqualToString:@"appearance"])
        {
            [inspectorContainer addInspectorView:[appearanceController inspectorView] expanded:YES];
        }
        else
        {
            if ([identifier isEqualToString:@"text"])
            {
                [inspectorContainer addInspectorView:[textController inspectorView] expanded:YES];
                [[NSNotificationCenter defaultCenter] addObserver:field selector:@selector(updateFieldName:) name:FormFieldNameChangeNotification object:textController];
                [[NSNotificationCenter defaultCenter] addObserver:field selector:@selector(updateFieldSize:) name:FormFieldSizeChangeNotification object:textController];
                [[NSNotificationCenter defaultCenter] addObserver:field selector:@selector(updateFieldPlaceholder:) name:FormFieldPlaceholderChangeNotification object:textController];
                
                [textController loadProperties:[field properties]];
            }
            else if ([identifier isEqualToString:@"radio"])
            {
                [inspectorContainer addInspectorView:[radioController inspectorView] expanded:YES];
                [[NSNotificationCenter defaultCenter] addObserver:field selector:@selector(updateFieldName:) name:FormFieldNameChangeNotification object:radioController];
                [[NSNotificationCenter defaultCenter] addObserver:field selector:@selector(updateFieldSize:) name:FormFieldSizeChangeNotification object:radioController];
                [[NSNotificationCenter defaultCenter] addObserver:field selector:@selector(updateFieldElementNumbers:) name:FormFieldNumberOfElementsChangeNotification object:radioController];
                [[NSNotificationCenter defaultCenter] addObserver:field selector:@selector(updateFieldElementLabel:) name:FormFieldElementLabelChangeNotification object:radioController];
                
                [radioController loadProperties:[field properties]];
            }
            else if ([identifier isEqualToString:@"checkbox"])
            {
                [inspectorContainer addInspectorView:[checkboxController inspectorView] expanded:YES];
                [[NSNotificationCenter defaultCenter] addObserver:field selector:@selector(updateFieldName:) name:FormFieldNameChangeNotification object:checkboxController];
                [[NSNotificationCenter defaultCenter] addObserver:field selector:@selector(updateFieldSize:) name:FormFieldSizeChangeNotification object:checkboxController];
                [[NSNotificationCenter defaultCenter] addObserver:field selector:@selector(updateFieldElementNumbers:) name:FormFieldNumberOfElementsChangeNotification object:checkboxController];
                [[NSNotificationCenter defaultCenter] addObserver:field selector:@selector(updateFieldElementLabel:) name:FormFieldElementLabelChangeNotification object:checkboxController];
                
                [checkboxController loadProperties:[field properties]];
            }
            else if ([identifier isEqualToString:@"select"])
            {
                [inspectorContainer addInspectorView:[selectController inspectorView] expanded:YES];
                [[NSNotificationCenter defaultCenter] addObserver:field selector:@selector(updateFieldName:) name:FormFieldNameChangeNotification object:selectController];
                [[NSNotificationCenter defaultCenter] addObserver:field selector:@selector(updateFieldSize:) name:FormFieldSizeChangeNotification object:selectController];
                [[NSNotificationCenter defaultCenter] addObserver:field selector:@selector(updateFieldElementNumbers:) name:FormFieldNumberOfElementsChangeNotification object:selectController];
                [[NSNotificationCenter defaultCenter] addObserver:field selector:@selector(updateFieldElementLabel:) name:FormFieldElementLabelChangeNotification object:selectController];
                
                [selectController loadProperties:[field properties]];
            }
            else if ([identifier isEqualToString:@"label"])
            {
                [inspectorContainer addInspectorView:[labelController inspectorView] expanded:YES];
                [[NSNotificationCenter defaultCenter] addObserver:field selector:@selector(updateFieldName:) name:FormFieldNameChangeNotification object:labelController];
                [[NSNotificationCenter defaultCenter] addObserver:field selector:@selector(updateFieldSize:) name:FormFieldSizeChangeNotification object:labelController];
                
                [labelController loadProperties:[field properties]];
            }
            
            [inspectorContainer addInspectorView:[layoutController inspectorView] expanded:NO];
            [[NSNotificationCenter defaultCenter] addObserver:field selector:@selector(updateFieldFrame:) name:FormFieldFrameChangeNotification object:layoutController];
        }
    }
}

- (void)sourceListDeleteKeyPressedOnRows:(NSNotification *)notification
{
    return;
    __block id item;
    NSIndexSet *selectedIndexes = [sourceList selectedRowIndexes];
    if ([selectedIndexes count] > 1)
    {
        [selectedIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
            item = [sourceList itemAtRow:index];
            if ([[grid subviews] containsObject:[item field]]) {
                [[item field] removeFromSuperview];
            }
        }];
    }
    else
    {
        item = [sourceList itemAtRow:[selectedIndexes firstIndex]];
        if ([[grid subviews] containsObject:[item field]]) {
            [[item field] removeFromSuperview];
            [self removeFromSidebar:item];
        }
    }
}

- (NSIndexSet *)sourceList:(PXSourceList*)aSourceList selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes
{
    __block id item;
    if  ([proposedSelectionIndexes count] > 1)
    {
        NSMutableIndexSet *set = [[NSMutableIndexSet alloc] initWithIndexSet:proposedSelectionIndexes];
        if ([proposedSelectionIndexes containsIndex:1] || [proposedSelectionIndexes containsIndex:2])
        {
            [set removeIndexesInRange:NSMakeRange(1,2)];
        }
        [set enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
            item = [aSourceList itemAtRow:index];
            [[NSNotificationCenter defaultCenter] removeObserver:item];
            if ([item respondsToSelector:@selector(isCategory)]) {
                if ([item isCategory]) {
                    [set removeIndex:index];
                }
            }
        }];
        return set;
    }
    else
    {
        item = [aSourceList itemAtRow:[proposedSelectionIndexes firstIndex]];
        [[NSNotificationCenter defaultCenter] removeObserver:item];
        if ([item respondsToSelector:@selector(isCategory)]) {
            if (![item isCategory]) {
                return proposedSelectionIndexes;
            }
        }
    }
    return [NSIndexSet indexSet];
}

- (BOOL)sourceList:(PXSourceList*)aSourceList isUnselectable:(id)item
{
    if ([item respondsToSelector:@selector(isCategory)]) {
        return [item isCategory];
    }
    return NO;
}


#pragma mark -
#pragma mark NSSplitView Delegate Methods

- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)offset
{
    if (offset == 1)
        return [sender frame].size.width - 250.0f;
    else
        return 125.0f;
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)offset
{
    if (offset == 1)
        return [sender frame].size.width - 125.0f;
    else
        return 250.0f;
}

- (BOOL)splitView:(NSSplitView *)aSplitView canCollapseSubview:(NSView *)subview
{
    return NO;
}

-(void)splitView:(NSSplitView *)aSplitView resizeSubviewsWithOldSize:(NSSize)oldSize {
    NSView *leftView = [[aSplitView subviews] objectAtIndex:0];
    NSView *midView = [[aSplitView subviews] objectAtIndex:1];
    NSView *rightView = [[aSplitView subviews] objectAtIndex:2];
    float dividerThickness = [aSplitView dividerThickness];

    NSRect leftFrame = [leftView frame];
    NSRect midFrame = [midView frame];
    NSRect rightFrame = [rightView frame];
    
    NSRect newFrame = [aSplitView frame];
    leftFrame.size.height = newFrame.size.height;
    midFrame.size.width = newFrame.size.width - leftFrame.size.width - rightFrame.size.width - (2*dividerThickness);
    midFrame.size.height = newFrame.size.height;
    midFrame.origin.x = leftFrame.size.width + dividerThickness;
    rightFrame.size.height = newFrame.size.height;
    rightFrame.origin.x = leftFrame.size.width + midFrame.size.width + (2*dividerThickness);
    
    [leftView setFrame:leftFrame];
    [midView setFrame:midFrame];
    [rightView setFrame:rightFrame];
}

#pragma mark -
#pragma mark Interface Builder Actions

- (IBAction)alignSelectedObjects:(id)sender
{
    NSInteger alignment = [sender selectedSegment];
    switch (alignment)
	{
		case kObjAlignLeft:
		{
			break;
		}

		case kObjAlignHorizMid:
		{
			break;
		}

		case kObjAlignRight:
		{
			break;
		}

		case kObjAlignTop:
		{
			break;
		}

        case kObjAlignVertMid:
		{
			break;
		}

        case kObjAlignBot:
		{
			break;
		}
	}
    
    [sender setSelectedSegment:-1]; //deselect
}

@end