//
//  InspectorViewController.h
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JUInspectorView.h"
#import "FormFieldNotifications.h"
#import "FormFieldDelegate.h"

@interface InspectorViewController : NSViewController<FormFieldDelegate>

- (JUInspectorView *)inspectorView;

extern NSString *FormFieldChangeNameNotification;
extern NSString *FormFieldFrameChangeNotification;
extern NSString *FormFieldNumberOfElementsChangeNotification;
extern NSString *FormFieldElementLabelChangeNotification;
extern NSString *FormFieldPlaceholderChangeNotification;

- (IBAction)changeName:(id)sender;
- (IBAction)changeSize:(id)sender;
- (IBAction)changeFrame:(id)sender;

- (IBAction)changeNumberOfElements:(id)sender;
- (IBAction)changeElement:(id)sender;
- (IBAction)changeElementLabel:(id)sender;
- (IBAction)changePlaceholder:(id)sender;

- (void)loadProperties:(NSDictionary *)properties;

@end
