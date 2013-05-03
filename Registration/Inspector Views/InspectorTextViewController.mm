//
//  InspectorTextViewController.m
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "InspectorTextViewController.h"

@interface InspectorTextViewController ()

@end

@implementation InspectorTextViewController

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

//- (void)frameChanged:(NSRect)newFrame;
//
//- (void)numberOfElementsChanged:(NSInteger)newNumberOfElements;
//- (void)elementLabelChanged:(NSString *)newLabel forElementAtIndex:(NSInteger)index;
//
//- (void)placeholderChanged:(NSString *)newPlaceholder;

- (void)loadProperties:(NSDictionary *)properties
{
    [name setStringValue:[properties objectForKey:@"name"]];
    [placeholder setStringValue:[properties objectForKey:@"placeholder"]];
    [size selectItemWithTitle:[properties objectForKey:@"size"]];
}

@end
