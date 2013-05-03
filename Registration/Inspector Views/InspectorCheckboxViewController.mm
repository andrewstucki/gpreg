//
//  InspectorCheckboxViewController.m
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "InspectorCheckboxViewController.h"

@interface InspectorCheckboxViewController ()
{
    NSMutableArray *currentElements;
}
@end

@implementation InspectorCheckboxViewController

@synthesize numberOfElementsValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)nameChanged:(NSString *)newName
{
    [name setStringValue:newName];
}

- (void)loadProperties:(NSDictionary *)properties
{
    [name setStringValue:[properties objectForKey:@"name"]];
    [size selectItemWithTitle:[properties objectForKey:@"size"]];
    
    currentElements = [properties objectForKey:@"elements"];
    numberOfElementsValue = [currentElements count];
    
    [numberOfElements setStringValue:[NSString stringWithFormat:@"%lu",numberOfElementsValue]];

    [elementNumber removeAllItems];
    for (NSUInteger i = 0; i < numberOfElementsValue; i++)
    {
        [elementNumber addItemWithTitle:[NSString stringWithFormat:@"%lu",i+1]];
    }
    
    [elementNumber selectItemAtIndex:0];
    [elementLabel setStringValue:[currentElements objectAtIndex:0]];
}

- (IBAction)changeNumberOfElements:(id)sender
{
    NSNumber *num = [NSNumber numberWithInteger:numberOfElementsValue];
    NSInteger cur = [elementNumber numberOfItems];
    while (numberOfElementsValue < cur)
    {
        [elementNumber removeItemAtIndex:cur-1];
        [currentElements removeObjectAtIndex:cur-1];
        cur--;
    }
    
    while (numberOfElementsValue > cur)
    {
        [elementNumber addItemWithTitle:[NSString stringWithFormat:@"%lu", cur+1]];
        [currentElements addObject:@"Checkbox"];
        cur++;
    }
    
    NSDictionary *userValues = [NSDictionary dictionaryWithObject:num forKey:@"numberOfElements"];
    [[NSNotificationCenter defaultCenter] postNotificationName:FormFieldNumberOfElementsChangeNotification object:self userInfo:userValues];
}

- (IBAction)changeElement:(id)sender
{
    [elementLabel setStringValue:[currentElements objectAtIndex:[sender indexOfSelectedItem]]];
}

- (IBAction)changeElementLabel:(id)sender
{
    NSNumber *elementIndex = [NSNumber numberWithInteger:[elementNumber indexOfSelectedItem]];
    NSString *newElementName = [sender stringValue];
    [currentElements replaceObjectAtIndex:[elementIndex integerValue] withObject:newElementName];
    NSDictionary *userValues = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:elementIndex,newElementName,nil] forKeys:[NSArray arrayWithObjects:@"elementNumber", @"elementLabel", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName:FormFieldElementLabelChangeNotification object:self userInfo:userValues];
}

@end
