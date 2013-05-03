//
//  FormLayoutBackgroundView.m
//  Registration
//
//  Created by Andrew Stucki on 4/16/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "FormLayoutGridView.h"

#import "NSControl+FormField.h"

@implementation FormLayoutGridView

@synthesize selectionIndexes;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        selectionIndexes = [NSIndexSet indexSet];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor colorWithPatternImage:[NSImage imageNamed:@"grid.png"]] set];
//    [[NSColor whiteColor] set];
    // Fill the entire view with the image.
    [NSBezierPath fillRect:[self bounds]];
    
    // Draw the background background.
//    [[NSColor whiteColor] set];
//    NSRectFill(rect);
    
    // Draw the grid.
//    [_grid drawRect:rect inView:self];
    
    // Draw every graphic that intersects the rectangle to be drawn. In Sketch the frontmost graphics have the lowest indexes.
    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    NSArray *fields = [self subviews];
    NSInteger fieldCount = [fields count];
    for (NSInteger index = fieldCount - 1; index>=0; index--) {
        NSControl *field = [fields objectAtIndex:index];
        NSRect fieldBounds = [field boundsOrFrame];
        
        NSLog(@"dirtyRect: %f, %f, %f, %f", dirtyRect.origin.x, dirtyRect.origin.y, dirtyRect.size.width, dirtyRect.size.height);
        NSLog(@"fieldBounds: %f, %f, %f, %f", fieldBounds.origin.x, fieldBounds.origin.y, fieldBounds.size.width, fieldBounds.size.height);
        
        if (NSIntersectsRect(dirtyRect, fieldBounds)) {
            
            // Figure out whether or not to draw selection handles on the graphic. Selection handles are drawn for all selected objects except:
            // - While the selected objects are being moved.
            // - For the object actually being created or edited, if there is one.
            BOOL drawSelectionHandles = NO;
            if (!isHidingHandles) {
                NSLog(@"not hiding handles");
                drawSelectionHandles = [selectionIndexes containsIndex:index];
                NSLog(@"draw handles: %d", drawSelectionHandles);
            }
            
            // Draw the graphic, possibly with selection handles.
            [currentContext saveGraphicsState];
            [NSBezierPath clipRect:fieldBounds];
//            if ([field visibleRect])
//            [field drawField:fieldBounds];
            [field setNeedsDisplay:YES withSelectionHandles:drawSelectionHandles];
//            if (drawSelectionHandles) {
//                [field drawHandlesInView:self];
//            }
            [currentContext restoreGraphicsState];
            
        }
    }
    
    // If the user is in the middle of selecting draw the selection rectangle.
    if (!NSEqualRects(marqueeSelectionBounds, NSZeroRect)) {
        [[NSColor knobColor] set];
        NSFrameRect(marqueeSelectionBounds);
    }
    
}

- (NSArray *)selectedFields {
    
    // Simple, because we made sure -graphics and -selectionIndexes never return nil.
    return [[self subviews] objectsAtIndexes:[self selectionIndexes]];
    
}

- (void)selectAndTrackMouseWithEvent:(NSEvent *)event {
    
    // Are we changing the existing selection instead of setting a new one?
    BOOL modifyingExistingSelection = ([event modifierFlags] & NSShiftKeyMask) ? YES : NO;
    
    // Has the user clicked on a graphic?
    NSPoint mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
    NSUInteger clickedFieldIndex;
    BOOL clickedFieldIsSelected;
    NSInteger clickedFieldHandle;
    NSControl *clickedField = [self fieldUnderPoint:mouseLocation index:&clickedFieldIndex isSelected:&clickedFieldIsSelected handle:&clickedFieldHandle];
    if (clickedField) {
        
        // Clicking on a graphic knob takes precedence.
        if (clickedFieldHandle!=kFieldNoHandle) {
            NSLog(@"Handle");
            // The user clicked on a graphic's handle. Let the user drag it around.
            [self resizeField:clickedField usingHandle:clickedFieldHandle withEvent:event];
            
        } else {
            
            // The user clicked on a graphic's contents. Update the selection.
            if (modifyingExistingSelection) {
                NSLog(@"Modify");
                if (clickedFieldIsSelected) {
                    NSLog(@"Removing");
                    // Remove the graphic from the selection.
                    NSMutableIndexSet *newSelectionIndexes = [[self selectionIndexes] mutableCopy];
                    [newSelectionIndexes removeIndex:clickedFieldIndex];
                    [self changeSelectionIndexes:newSelectionIndexes];
                    clickedFieldIsSelected = NO;
                
                } else {
                    NSLog(@"Addinging");
                    // Add the graphic to the selection.
                    NSMutableIndexSet *newSelectionIndexes = [[self selectionIndexes] mutableCopy];
                    [newSelectionIndexes addIndex:clickedFieldIndex];
                    [self changeSelectionIndexes:newSelectionIndexes];
                    clickedFieldIsSelected = YES;
                    
                }
            } else {
                NSLog(@"New Selection");
                // If the graphic wasn't selected before then it is now, and none of the rest are.
                if (!clickedFieldIsSelected) {
                    [self changeSelectionIndexes:[NSIndexSet indexSetWithIndex:clickedFieldIndex]];
                    clickedFieldIsSelected = YES;
                }
                
            }
            
            // Is the graphic that the user has clicked on now selected?
            if (clickedFieldIsSelected) {
                
                // Yes. Let the user move all of the selected objects.
                [self moveSelectedFieldsWithEvent:event];
                
            } else {
                NSLog(@"Ignoring");

                // No. Just swallow mouse events until the user lets go of the mouse button. We don't even bother autoscrolling here.
                while ([event type]!=NSLeftMouseUp) {
                    event = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
                }
                
            }
            
        }
        
    } else {
        
        NSLog(@"Didn't click field");
	    
        // The user clicked somewhere other than on a graphic. Clear the selection, unless the user is holding down the shift key.
        if (!modifyingExistingSelection) {
            NSLog(@"removing indexes");
            [self changeSelectionIndexes:[NSIndexSet indexSet]];
        }
        
        // The user clicked on a point where there is no graphic. Select and deselect graphics until the user lets go of the mouse button.
        [self marqueeSelectWithEvent:event];
        
    }
    
}

- (NSControl *)fieldUnderPoint:(NSPoint)point index:(NSUInteger *)outIndex isSelected:(BOOL *)outIsSelected handle:(NSInteger *)outHandle {
    NSLog(@"Checking if under point");

    // We don't touch *outIndex, *outIsSelected, or *outHandle if we return nil. Those values are undefined if we don't return a match.
    
    // Search through all of the graphics, front to back, looking for one that claims that the point is on a selection handle (if it's selected) or in the contents of the graphic itself.
    NSControl *fieldToReturn = nil;
    NSArray *fields = [self subviews];
    NSUInteger fieldCount = [fields count];
    for (NSUInteger index = 0; index<fieldCount; index++) {
        NSControl *field = [fields objectAtIndex:index];
        
        NSLog(@"Checking index %ld: %@", index, [field className]);
        NSLog(@"Currently at: %f, %f, %f, %f", [field boundsOrFrame].origin.x, [field boundsOrFrame].origin.y, [field boundsOrFrame].size.width, [field boundsOrFrame].size.height);
        NSLog(@"Checking point: %f, %f", point.x, point.y);
        
        // Do a quick check to weed out graphics that aren't even in the neighborhood.
        if (NSPointInRect(point, [field boundsOrFrame])) {
            NSLog(@"under");
            // Check the graphic's selection handles first, because they take precedence when they overlap the graphic's contents.
            BOOL fieldIsSelected = [selectionIndexes containsIndex:index];
            if (fieldIsSelected) {
                NSLog(@"selected");
                NSInteger handle = [field handleUnderPoint:point];
                if (handle!=kFieldNoHandle) {
                    NSLog(@"Handle");
                    // The user clicked on a handle of a selected graphic.
                    fieldToReturn = field;
                    if (outHandle) {
                        *outHandle = handle;
                    }
                    
                }
            }
            
            if (!fieldToReturn) {
                
                NSLog(@"checking contents");
                BOOL clickedOnFieldContents = [field isContentsUnderPoint:point];
                if (clickedOnFieldContents) {
                    NSLog(@"Contents");
                    // The user clicked on the contents of a graphic.
                    fieldToReturn = field;
                    if (outHandle) {
                        *outHandle = kFieldNoHandle;
                    }
                    
                }
            }
            
            if (fieldToReturn) {
                
                // Return values and stop looking.
                if (outIndex) {
                    *outIndex = index;
                }
                if (outIsSelected) {
                    *outIsSelected = fieldIsSelected;
                }
                break;
                
            }
            
        }
        
    }
    return fieldToReturn;
    
}

- (void)mouseDown:(NSEvent *)event {
    
    // If a graphic has been being edited (in Sketch SKTTexts are the only ones that are "editable" in this sense) then end editing.
//    [self stopEditing];
    
    // Is a tool other than the Selection tool selected?
//    Class graphicClassToInstantiate = [[SKTToolPaletteController sharedToolPaletteController] currentGraphicClass];
//    if (graphicClassToInstantiate) {
//        
//        // Create a new graphic and then track to size it.
//        [self createGraphicOfClass:graphicClassToInstantiate withEvent:event];
//        
//    } else {
//        
//        // Double-clicking with the selection tool always means "start editing," or "do nothing" if no editable graphic is double-clicked on.
//        SKTGraphic *doubleClickedGraphic = nil;
//        if ([event clickCount]>1) {
//            NSPoint mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
//            doubleClickedGraphic = [self graphicUnderPoint:mouseLocation index:NULL isSelected:NULL handle:NULL];
//            if (doubleClickedGraphic) {
//                [self startEditingGraphic:doubleClickedGraphic];
//            }
//        }
//        if (!doubleClickedGraphic) {
//            
//            // Update the selection and/or move graphics or resize graphics.
            [self selectAndTrackMouseWithEvent:event];
            
//        }
    
//    }
    
}

- (void)marqueeSelectWithEvent:(NSEvent *)event {
    
    // Dequeue and handle mouse events until the user lets go of the mouse button.
    NSIndexSet *oldSelectionIndexes = [self selectionIndexes];
    NSPoint originalMouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
    while ([event type]!=NSLeftMouseUp) {
        event = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        [self autoscroll:event];
        NSPoint currentMouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
        
        // Figure out a new a selection rectangle based on the mouse location.
        NSRect newMarqueeSelectionBounds = NSMakeRect(fmin(originalMouseLocation.x, currentMouseLocation.x), fmin(originalMouseLocation.y, currentMouseLocation.y), fabs(currentMouseLocation.x - originalMouseLocation.x), fabs(currentMouseLocation.y - originalMouseLocation.y));
        if (!NSEqualRects(newMarqueeSelectionBounds, marqueeSelectionBounds)) {
            
            // Erase the old selection rectangle and draw the new one.
            [self setNeedsDisplayInRect:marqueeSelectionBounds];
            marqueeSelectionBounds = newMarqueeSelectionBounds;
            [self setNeedsDisplayInRect:marqueeSelectionBounds];
            
            // Either select or deselect all of the graphics that intersect the selection rectangle.
            NSIndexSet *indexesOfFieldsInRubberBand = [self indexesOfFieldsIntersectingRect:marqueeSelectionBounds];
            NSMutableIndexSet *newSelectionIndexes = [oldSelectionIndexes mutableCopy];
            for (NSUInteger index = [indexesOfFieldsInRubberBand firstIndex]; index!=NSNotFound; index = [indexesOfFieldsInRubberBand indexGreaterThanIndex:index]) {
                if ([newSelectionIndexes containsIndex:index]) {
                    [newSelectionIndexes removeIndex:index];
                } else {
                    [newSelectionIndexes addIndex:index];
                }
            }
            [self changeSelectionIndexes:newSelectionIndexes];            
        }
    }
    
    // Schedule the drawing of the place wherew the rubber band isn't anymore.
    [self setNeedsDisplayInRect:marqueeSelectionBounds];
    
    // Make it not there.
    marqueeSelectionBounds = NSZeroRect;
    
}

- (NSIndexSet *)indexesOfFieldsIntersectingRect:(NSRect)rect {
    NSMutableIndexSet *indexSetToReturn = [NSMutableIndexSet indexSet];
    NSArray *fields = [self subviews];
    NSUInteger fieldCount = [fields count];
    for (NSUInteger index = 0; index<fieldCount; index++) {
        NSControl *field = [fields objectAtIndex:index];
        if (NSIntersectsRect(rect, [field boundsOrFrame])) {
            [indexSetToReturn addIndex:index];
        }
    }
    return indexSetToReturn;
}

- (void)changeSelectionIndexes:(NSIndexSet *)indexes {
    
    // After all of that talk, this method isn't invoking -validateValue:forKeyPath:error:. It will, once we come up with an example of invalid selection indexes for this case.
    
    // It will also someday take any value transformer specified as a binding option into account, so you have an example of how to do that.
    
    // Set the selection index set in the bound-to object (an array controller, in Sketch's case). The bound-to object is responsible for being KVO-compliant enough that all observers of the bound-to property get notified of the setting. Trying to set the selection indexes of a graphic view whose selection indexes aren't bound to anything is a programming error.
    selectionIndexes = indexes;    
}

- (void)moveSelectedFieldsWithEvent:(NSEvent *)event {
    NSLog(@"Moving");
    NSPoint lastPoint, curPoint;
    NSArray *selFields = [self selectedFields];
    BOOL didMove = NO, isMoving = NO;
    BOOL echoToRulers = [[self enclosingScrollView] rulersVisible];
    NSRect selBounds = [self boundsOfFields:selFields];
    
    lastPoint = [self convertPoint:[event locationInWindow] fromView:nil];
    NSPoint selOriginOffset = NSMakePoint((lastPoint.x - selBounds.origin.x), (lastPoint.y - selBounds.origin.y));
    if (echoToRulers) {
        [self beginEchoingMoveToRulers:selBounds];
    }
    
    while ([event type]!=NSLeftMouseUp) {
        event = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        [self autoscroll:event];
        curPoint = [self convertPoint:[event locationInWindow] fromView:nil];
        if (!isMoving && ((fabs(curPoint.x - lastPoint.x) >= 2.0) || (fabs(curPoint.y - lastPoint.y) >= 2.0))) {
            isMoving = YES;
            isHidingHandles = YES;
        }
        if (isMoving) {
//            if (_grid) {
//                NSPoint boundsOrigin;
//                boundsOrigin.x = curPoint.x - selOriginOffset.x;
//                boundsOrigin.y = curPoint.y - selOriginOffset.y;
//                boundsOrigin  = [_grid constrainedPoint:boundsOrigin];
//                curPoint.x = boundsOrigin.x + selOriginOffset.x;
//                curPoint.y = boundsOrigin.y + selOriginOffset.y;
//            }
            if (!NSEqualPoints(lastPoint, curPoint)) {
                [self translateFields:selFields byX:(curPoint.x - lastPoint.x) y:(curPoint.y - lastPoint.y)];
                didMove = YES;
                if (echoToRulers) {
                    [self continueEchoingMoveToRulers:NSMakeRect(curPoint.x - selOriginOffset.x, curPoint.y - selOriginOffset.y, NSWidth(selBounds),NSHeight(selBounds))];
                }
                // Adjust the delta that is used for cascading pastes.  Pasting and then moving the pasted graphic is the way you determine the cascade delta for subsequent pastes.
//                _pasteCascadeDelta.x += (curPoint.x - lastPoint.x);
//                _pasteCascadeDelta.y += (curPoint.y - lastPoint.y);
            }
            lastPoint = curPoint;
        }
    }
    
    if (echoToRulers)  {
        [self stopEchoingMoveToRulers];
    }
    if (isMoving) {
        isHidingHandles = NO;
        [self setNeedsDisplayInRect:[self boundsOfFields:selFields]];
        if (didMove) {
            // Only if we really moved.
//            [[self undoManager] setActionName:NSLocalizedStringFromTable(@"Move", @"UndoStrings", @"Action name for moves.")];
        }
    }
}

///switch bounds to frame

- (NSRect)boundsOfFields:(NSArray *)fields {
    
    // The bounds of an array of graphics is the union of all of their bounds.
    NSRect bounds = NSZeroRect;
    NSUInteger fieldCount = [fields count];
    if (fieldCount>0) {
        bounds = [[fields objectAtIndex:0] boundsOrFrame];
        for (NSUInteger index = 1; index<fieldCount; index++) {
            bounds = NSUnionRect(bounds, [[fields objectAtIndex:index] boundsOrFrame]);
        }
    }
    return bounds;
    
}

- (void)beginEchoingMoveToRulers:(NSRect)echoRect {
    NSRulerView *horizontalRuler = [[self enclosingScrollView] horizontalRulerView];
    NSRulerView *verticalRuler = [[self enclosingScrollView] verticalRulerView];
    
    NSRect newHorizontalRect = [self convertRect:echoRect toView:horizontalRuler];
    NSRect newVerticalRect = [self convertRect:echoRect toView:verticalRuler];
    
    [horizontalRuler moveRulerlineFromLocation:-1.0 toLocation:NSMinX(newHorizontalRect)];
    [horizontalRuler moveRulerlineFromLocation:-1.0 toLocation:NSMidX(newHorizontalRect)];
    [horizontalRuler moveRulerlineFromLocation:-1.0 toLocation:NSMaxX(newHorizontalRect)];
    
    [verticalRuler moveRulerlineFromLocation:-1.0 toLocation:NSMinY(newVerticalRect)];
    [verticalRuler moveRulerlineFromLocation:-1.0 toLocation:NSMidY(newVerticalRect)];
    [verticalRuler moveRulerlineFromLocation:-1.0 toLocation:NSMaxY(newVerticalRect)];
    
    rulerEchoedBounds = echoRect;
}

- (void)continueEchoingMoveToRulers:(NSRect)echoRect {
    NSRulerView *horizontalRuler = [[self enclosingScrollView] horizontalRulerView];
    NSRulerView *verticalRuler = [[self enclosingScrollView] verticalRulerView];
    
    NSRect oldHorizontalRect = [self convertRect:rulerEchoedBounds toView:horizontalRuler];
    NSRect oldVerticalRect = [self convertRect:rulerEchoedBounds toView:verticalRuler];
    
    NSRect newHorizontalRect = [self convertRect:echoRect toView:horizontalRuler];
    NSRect newVerticalRect = [self convertRect:echoRect toView:verticalRuler];
    
    [horizontalRuler moveRulerlineFromLocation:NSMinX(oldHorizontalRect) toLocation:NSMinX(newHorizontalRect)];
    [horizontalRuler moveRulerlineFromLocation:NSMidX(oldHorizontalRect) toLocation:NSMidX(newHorizontalRect)];
    [horizontalRuler moveRulerlineFromLocation:NSMaxX(oldHorizontalRect) toLocation:NSMaxX(newHorizontalRect)];
    
    [verticalRuler moveRulerlineFromLocation:NSMinY(oldVerticalRect) toLocation:NSMinY(newVerticalRect)];
    [verticalRuler moveRulerlineFromLocation:NSMidY(oldVerticalRect) toLocation:NSMidY(newVerticalRect)];
    [verticalRuler moveRulerlineFromLocation:NSMaxY(oldVerticalRect) toLocation:NSMaxY(newVerticalRect)];
    
    rulerEchoedBounds = echoRect;
}

- (void)stopEchoingMoveToRulers {
    NSRulerView *horizontalRuler = [[self enclosingScrollView] horizontalRulerView];
    NSRulerView *verticalRuler = [[self enclosingScrollView] verticalRulerView];
    
    NSRect oldHorizontalRect = [self convertRect:rulerEchoedBounds toView:horizontalRuler];
    NSRect oldVerticalRect = [self convertRect:rulerEchoedBounds toView:verticalRuler];
    
    [horizontalRuler moveRulerlineFromLocation:NSMinX(oldHorizontalRect) toLocation:-1.0];
    [horizontalRuler moveRulerlineFromLocation:NSMidX(oldHorizontalRect) toLocation:-1.0];
    [horizontalRuler moveRulerlineFromLocation:NSMaxX(oldHorizontalRect) toLocation:-1.0];
    
    [verticalRuler moveRulerlineFromLocation:NSMinY(oldVerticalRect) toLocation:-1.0];
    [verticalRuler moveRulerlineFromLocation:NSMidY(oldVerticalRect) toLocation:-1.0];
    [verticalRuler moveRulerlineFromLocation:NSMaxY(oldVerticalRect) toLocation:-1.0];
    
    rulerEchoedBounds = NSZeroRect;
}

- (void)translateFields:(NSArray *)fields byX:(CGFloat)deltaX y:(CGFloat)deltaY {
    
    // Pretty simple.
    NSUInteger fieldCount = [fields count];
    for (NSUInteger index = 0; index<fieldCount; index++) {
        id field = [fields objectAtIndex:index];
        [field setFrame:NSOffsetRect([field boundsOrFrame], deltaX, deltaY)];
    }
    
}

- (void)resizeField:(NSControl *)field usingHandle:(NSInteger)handle withEvent:(NSEvent *)event {
    
    BOOL echoToRulers = [[self enclosingScrollView] rulersVisible];
    if (echoToRulers) {
        [self beginEchoingMoveToRulers:[field bounds]];
    }
    
    while ([event type]!=NSLeftMouseUp) {
        event = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        [self autoscroll:event];
        NSPoint handleLocation = [self convertPoint:[event locationInWindow] fromView:nil];
//        if (_grid) {
//            handleLocation = [_grid constrainedPoint:handleLocation];
//        }
        handle = [field resizeByMovingHandle:handle toPoint:handleLocation];
        if (echoToRulers) {
            [self continueEchoingMoveToRulers:[field bounds]];
        }
    }
    
    if (echoToRulers) {
        [self stopEchoingMoveToRulers];
    }
    
//    [[self undoManager] setActionName:NSLocalizedStringFromTable(@"Resize", @"UndoStrings", @"Action name for resizes.")];
    
}


@end
