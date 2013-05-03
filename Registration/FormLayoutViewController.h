//
//  FormCreationBarDelegate.h
//  Registration
//
//  Created by Andrew Stucki on 4/15/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FormLayoutView.h"
#import "FormLayoutGridView.h"
#import "FormCreationBarCell.h"
#import "InspectorViews.h"
#import "FormCells.h"

#import "PXSourceList.h"
#import "JUInspectorView.h"
#import "CNSplitView.h"

@interface FormLayoutViewController : NSViewController <PXSourceListDataSource, PXSourceListDelegate, CNSplitViewToolbarDelegate, NSSplitViewDelegate, NSMenuDelegate>
{
@private
    IBOutlet CNSplitView *splitView;
    
    IBOutlet PXSourceList *sourceList;
    NSMutableArray *creationBarItems;
    NSPopUpButton *popupButton;
    
    FormCreationBarCell *textFields;
    FormCreationBarCell *radioFields;
    FormCreationBarCell *checkBoxFields;
    FormCreationBarCell *selectFields;
    FormCreationBarCell *labels;
    
    IBOutlet FormLayoutView *background;
    IBOutlet FormLayoutGridView *grid;
    
    IBOutlet JUInspectorViewContainer *inspectorContainer;

    InspectorAlignmentViewController *alignmentController;
    InspectorAppearanceViewController *appearanceController;
    InspectorAttributesViewController *attributesController;
    InspectorLayoutViewController *layoutController;
    
    InspectorCheckboxViewController *checkboxController;
    InspectorLabelViewController *labelController;
    InspectorRadioViewController *radioController;
    InspectorSelectViewController *selectController;
    InspectorTextViewController *textController;    
}

- (IBAction)alignSelectedObjects:(id)sender;

@end
