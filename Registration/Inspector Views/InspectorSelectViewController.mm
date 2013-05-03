//
//  InspectorSelectView.m
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "InspectorSelectViewController.h"

@interface InspectorSelectViewController ()

@end

@implementation InspectorSelectViewController

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

    //elements
}

@end
