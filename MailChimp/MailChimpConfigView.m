//
//  MailChimpConfigView.m
//  MailChimp
//
//  Created by Dean Thomas on 03/11/2014.
//  Copyright (c) 2014 SpikedSoftware. All rights reserved.
//

#import "MailChimpConfigView.h"
#import "MailChimp.h"
#import "APIHelper.h"

@interface MailChimpConfigView ()

@property (strong, nonatomic) NSTextField *apiKey;
@property (strong, nonatomic) NSPopUpButton *listPopup;
@property (strong, nonatomic) NSArray *listsAvailable;

@end

@implementation MailChimpConfigView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(id)initWithFrame:(NSRect)frame plugin:(AMPlugin *)pluginIn
{
    self = [super initWithFrame:frame plugin:pluginIn];
    if (self)
    {
        @try {
            
            float x = 0, y = 0;
            
            NSTextView *apiKeyLabel = [[NSTextView alloc] initWithFrame:CGRectMake(x, y, 75.0f, 17.0f)];
            [apiKeyLabel setString:@"API Key"];
            [apiKeyLabel setEditable:false];
            [apiKeyLabel setSelectable:false];
            [apiKeyLabel setDrawsBackground:false];
            y += apiKeyLabel.frame.size.height + 5.0f;
            
            self.apiKey = [[NSTextField alloc] initWithFrame:CGRectMake(x, y, 260.0f, 22.0f)];
            [self.apiKey setEditable: YES];
            [self.apiKey setPlaceholderString:@"API Key from your account"];
            
            NSString *apiKey = [[self myPlugin] getAPIKey];
            if (apiKey != nil)
                [self.apiKey setStringValue:apiKey];
            
            x += self.apiKey.frame.size.width + 5.0f;
            
            NSButton *apiKeyTest = [[NSButton alloc] initWithFrame:CGRectMake(x, y, 100.0f, 25.0f)];
            [apiKeyTest setTitle:@"Refresh List"];
            [apiKeyTest setButtonType:NSMomentaryPushInButton];
            [apiKeyTest setBezelStyle:NSRoundedBezelStyle];
            [apiKeyTest setTarget:self];
            [apiKeyTest setAction:@selector(apiKeyTest_clicked)];
            
            x = 0;
            y += apiKeyTest.frame.size.height + 5.0f;
            
            NSTextView *listLabel = [[NSTextView alloc] initWithFrame:CGRectMake(x, y, 75.0f, 17.0f)];
            [listLabel setString:@"Default List"];
            [listLabel setEditable:false];
            [listLabel setSelectable:false];
            [listLabel setDrawsBackground:false];
            
            x = 0;
            y += listLabel.frame.size.height + 5.0f;
            
            self.listPopup = [[NSPopUpButton alloc] initWithFrame:CGRectMake(0, y, 220.0f, 25.0f) pullsDown:false];
            [self.listPopup setTarget:self];
            [self.listPopup setAction:@selector(popUpAction:)];
            
            NSArray *existingLists = [[self myPlugin] getLists];
            NSString *selectedItem = [[self myPlugin] getDefaultListId];
            [self.listPopup removeAllItems];
            [self.listPopup addItemWithTitle:@"Select One..."];
            
            
            for (int i = 0; i < existingLists.count; i ++)
            {
                NSString *name = [[existingLists objectAtIndex:i] objectForKey:@"name"];
                NSString *itemId = [[existingLists objectAtIndex:i] objectForKey:@"id"];
                [self.listPopup addItemWithTitle:name];
                
                //Do we have a selected item
                if (selectedItem != nil)
                {
                    if ([itemId isEqualTo:selectedItem])
                        [self.listPopup selectItemAtIndex:(i+1)];
                }
            }
            
            x = 0;
            y += self.listPopup.frame.size.height + 25.0f;
            
            NSButton *saveButton = [[NSButton alloc] initWithFrame:CGRectMake(0, y, 120.0f, 25.0f)];
            [saveButton setTitle:@"Save Changes"];
            [saveButton setButtonType:NSMomentaryPushInButton];
            [saveButton setBezelStyle:NSRoundedBezelStyle];
            [saveButton setTarget:self];
            [saveButton setAction:@selector(saveChangesAction:)];
            
            [self addSubview:apiKeyLabel];
            [self addSubview:self.apiKey];
            [self addSubview:apiKeyTest];
            [self addSubview:listLabel];
            [self addSubview:self.listPopup];
            [self addSubview:saveButton];
                
        }
        @catch (NSException *exception) {
            NSAlert *alertView = [NSAlert new];
            [alertView setMessageText:@"Error when creating view"];
            [alertView runModal];
        }
        @finally {
            
        }
    }
    return self;
}

- (MailChimp*) myPlugin
{
    return (MailChimp*)self.plugin;
}

- (void) ReloadView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self LoadView];
    });
}

- (void) LoadView
{
    
}

#pragma mark 'Functionality behind UI Elements'
-(void)apiKeyTest_clicked
{
    NSString *apiKey = self.apiKey.stringValue;
    if (apiKey.length >= 36)
        [APIHelper getListsWithAPIKey:apiKey andDelegate:self];
    else
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"API Key not quite correct. Should be around 36 characters, with a datacenter code at the end, i.e. <apikey>-us9"];
        [alert runModal];
    }
    
    return;
}

-(void)popUpAction:(id)sender
{
}

-(void)saveChangesAction: (id)sender
{
    //Get the Selected List and the API Key, then save them
    MailChimp *plugin = (MailChimp *)[self plugin];
    NSString *message;
    BOOL shouldSave = YES;
    
    //Save the API Key
    if ([self.apiKey stringValue].length >= 36)
        [plugin setAPIKey:[self.apiKey stringValue]];
    else
    {
        shouldSave = NO;
        message = @"API Key not quite correct. Should be around 36 characters, with a datacenter code at the end, i.e. <apikey>-us9";
    }
    
    //Save the selected list
    NSUInteger selectedIndex = self.listPopup.indexOfSelectedItem;
    if (selectedIndex > 0)
    {
        MailChimp *plugin = (MailChimp *)[self plugin];
        NSArray *lists = [plugin getLists];
        NSDictionary *list = [lists objectAtIndex:(selectedIndex - 1)];
        [plugin setDefaultListId:[list objectForKey:@"id"]];
    }
    else
    {
        shouldSave = NO;
        message = @"You must select a default list";
    }
    
    if (shouldSave)
    {
        [plugin SavePreferences];
        message = @"Preferences have been saved.";
    }

    NSAlert *al = [[NSAlert alloc] init];
    [al setMessageText:message];
    [al runModal];
}

-(void)finishedCallFor:(NSString *)method withData:(NSDictionary *)dict
{
    if ([method isEqualToString:@"GetLists"])
    {
        //Run through all of the 'items' found, and bind them to the list
        [self.listPopup removeAllItems];
        [self.listPopup addItemWithTitle:@"Select One..."];
        
        NSArray *items = (NSArray *)[dict objectForKey:@"data"];
        for (int i = 0; i <items.count; i ++)
        {
            NSString *name = [[items objectAtIndex:i] objectForKey:@"name"];
            [self.listPopup addItemWithTitle:name];
        }
        
        //Now we know we have the items, lets store them...
        self.listsAvailable = items;
        [((MailChimp *)[self plugin]) setLists:items];
    }
}

@end
