//
//  InspectorViewController.m
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "InspectorViewController.h"

@interface InspectorViewController ()

@end

@implementation InspectorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (JUInspectorView *)inspectorView
{
    return (JUInspectorView *)[self view];
}

- (IBAction)changeName:(id)sender
{
    NSDictionary *userValues = [NSDictionary dictionaryWithObject:[sender stringValue] forKey:@"name"];
    [[NSNotificationCenter defaultCenter] postNotificationName:FormFieldNameChangeNotification object:self userInfo:userValues];
}

- (IBAction)changePlaceholder:(id)sender
{
    NSDictionary *userValues = [NSDictionary dictionaryWithObject:[sender stringValue] forKey:@"placeholder"];
    [[NSNotificationCenter defaultCenter] postNotificationName:FormFieldPlaceholderChangeNotification object:self userInfo:userValues];
}

- (IBAction)changeSize:(id)sender
{
    NSDictionary *userValues = [NSDictionary dictionaryWithObject:[sender titleOfSelectedItem] forKey:@"size"];
    [[NSNotificationCenter defaultCenter] postNotificationName:FormFieldSizeChangeNotification object:self userInfo:userValues];
}

- (IBAction)changeElement:(id)sender
{
    
}

- (IBAction)changeFrame:(id)sender
{
    
}

- (IBAction)changeNumberOfElements:(id)sender
{

}

- (IBAction)changeElementLabel:(id)sender
{
    
}

- (void)loadProperties:(NSDictionary *)properties
{
    
}

@end
