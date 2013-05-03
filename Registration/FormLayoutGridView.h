//
//  FormLayoutBackgroundView.h
//  Registration
//
//  Created by Andrew Stucki on 4/16/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FormLayoutGridView : NSView
{
    NSRect marqueeSelectionBounds;
    BOOL isHidingHandles;
    NSRect rulerEchoedBounds;
    NSObject *selectionIndexesContainer;
    NSString *selectionIndexesKeyPath;
}

@property NSIndexSet *selectionIndexes;

@end
