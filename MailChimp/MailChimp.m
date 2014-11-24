//
//  MailChimp.m
//  MailChimp
//
//  Created by Dean Thomas on 03/11/2014.
//  Copyright (c) 2014 SpikedSoftware. All rights reserved.
//

#import "MailChimp.h"
#import "MailChimpConfigView.h"
#import "APIHelper.h"

const NSString *apikey_key = @"apikey";
const NSString *defaultlistid_key = @"defaultlistid";
const NSString *availablelists_key = @"lists";

@implementation MailChimp

-(id)initWithbundle:(NSBundle *)bundleIn path:(NSString *)pathIn
{
    self = [super initWithbundle:bundleIn path:pathIn];
    if (self)
    {
        
    }
    return self;
}

-(BOOL)Load
{
    if (![super Load])
        return NO;
    
    return YES;
}

-(void)Enable
{
    
}

-(void)Disable
{
    
}

-(void)Invalid
{
    
}

-(void)Reload
{
    [self.myView ReloadView];
}

-(AMPView *)pluginview
{
    if (self.myView == nil)
        self.myView = [[MailChimpConfigView alloc] initWithFrame:NSZeroRect plugin:self];
    
    return self.myView;
}

-(NSString *)nametext
{
    return @"MailChimp";
}

-(NSString *)description
{
    return self.nametext;
}

-(NSString *)descriptiontext
{
    return @"Integrate MailChimp and AirMail, for easy management of your Mailing Lists";
}

-(NSString *)authortext
{
    return @"Dean Thomas";
}

-(NSString *)supportlink
{
    return @"http://www.spikedsoftware.com";
}

- (NSImage*) icon
{
    return [self.bundle imageForResource:@"Mailchimp"];
}

-(id)ampMenuActionItem:(NSArray *)messages
{
    //Get default list name
    NSString *defaultListName = nil;
    NSArray *lists = [self getLists];
    for ( int i = 0; i < lists.count; i ++ )
        if ([[lists[i] objectForKey:@"id"] isEqualToString:[self getDefaultListId]])
            defaultListName = [lists[i] objectForKey:@"name"];
    
    NSMenuItem *mailChimpItem = [[NSMenuItem alloc] initWithTitle:@"MailChimp" action:nil keyEquivalent:@""];
    NSMenu *subMenu = [NSMenu alloc];
    
    //Create more items for the various elements
    NSMenuItem *addAllFrom = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Send all From to '%@'", defaultListName] action:nil keyEquivalent:@""];
    [addAllFrom setRepresentedObject:@""];
    [addAllFrom setAction:@selector(sendFromToDefaultList:)];
    [addAllFrom setTarget:self];
    [subMenu addItem:addAllFrom];
    
    NSMenuItem *addAllTo = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Send all To to '%@'", defaultListName] action:nil keyEquivalent:@""];
    [addAllTo setRepresentedObject:@""];
    [addAllTo setAction:@selector(sendToToDefaultList:)];
    [addAllTo setTarget:self];
    [subMenu addItem:addAllTo];
    
    NSMenuItem *addAllCC = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Send all CC to '%@'", defaultListName] action:nil keyEquivalent:@""];
    [addAllCC setRepresentedObject:@""];
    [addAllCC setAction:@selector(sendCCToDefaultList:)];
    [addAllCC setTarget:self];
    [subMenu addItem:addAllCC];
    
    [mailChimpItem setSubmenu:subMenu];
    
    return mailChimpItem;
}

-(void)setAPIKey:(NSString *)apiKey
{
    [self.preferences setObject:apiKey forKey:apikey_key];
}

-(NSString *)getAPIKey
{
    return [self.preferences objectForKey:apikey_key];
}

-(void)setLists: (NSArray *)arr
{
    //JSONify it
    NSString *listsJson = [self serializeArray:arr];
    
    [self.preferences setObject:listsJson forKey:availablelists_key];
}

-(NSArray *)getLists
{
    NSString *listsJson = [self.preferences objectForKey:availablelists_key];
    
    if (listsJson == nil)
        return [NSArray new];
    
    NSArray *lists = [self deserializeArray:listsJson];
    
    return lists;
}

-(void)setDefaultListId:(NSString *)listId
{
    [self.preferences setObject:listId forKey:defaultlistid_key];
}

-(NSString *)getDefaultListId
{
    return [self.preferences objectForKey:defaultlistid_key];
}

-(BOOL)Save
{
    return [self SavePreferences];
}

-(void)sendAddressesToDefaultList: (NSArray *)emails
{
    //Let's make sure we have a default list...
    NSString *defaultListId = [self getDefaultListId];
    NSString *apiKey = [self getAPIKey];
    
    if (defaultListId == nil)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"No Default List has been selected! Choose one in the Plugin Preferences."];
        [alert runModal];
    }
    else
    {
        if (emails.count == 1)
        {
            //Single
            [APIHelper subscribeEmail:[emails objectAtIndex:0] toList:defaultListId withAPIKey:apiKey andDelegate:self];
        }
        else
        {
            //Multiple
            [APIHelper batchSubscribeEmail:emails toList:defaultListId withAPIKey:apiKey andDelegate:self];
        }
        
        [[NSSound soundNamed:@"Hero"] play];
    }
}

-(void)sendFromToDefaultList: (NSMenuItem *)item
{
    AMPMenuAction *action = item.representedObject;
    if(action && [action isKindOfClass:[AMPMenuAction class]])
    {
        NSMutableArray *emails = [NSMutableArray new];
        for ( int i = 0; i < action.messages.count; i ++ )
        {
            AMPMessage *msg = (AMPMessage *)[action.messages objectAtIndex:i];
            [emails addObject:msg.from.mail];
        }
        
        [self sendAddressesToDefaultList:emails];
    }
    
    return;
}

-(void)sendToToDefaultList: (NSMenuItem *)item
{
    AMPMenuAction *action = item.representedObject;
    if(action && [action isKindOfClass:[AMPMenuAction class]])
    {
        NSMutableArray *emails = [NSMutableArray new];
        for ( int i = 0; i < action.messages.count; i ++ )
        {
            AMPMessage *msg = (AMPMessage *)[action.messages objectAtIndex:i];
            for ( int t = 0; t < msg.to.count; t ++ )
                [emails addObject:((AMPAddress *)[msg.to objectAtIndex:t]).mail];
        }
        
        [self sendAddressesToDefaultList:emails];
    }

    return;
}

-(void)sendCCToDefaultList: (NSMenuItem *)item
{
    AMPMenuAction *action = item.representedObject;
    if(action && [action isKindOfClass:[AMPMenuAction class]])
    {
        NSMutableArray *emails = [NSMutableArray new];
        for ( int i = 0; i < action.messages.count; i ++ )
        {
            AMPMessage *msg = (AMPMessage *)[action.messages objectAtIndex:i];
            for ( int t = 0; t < msg.cc.count; t ++ )
                [emails addObject:((AMPAddress *)[msg.cc objectAtIndex:t]).mail];
        }
        
        [self sendAddressesToDefaultList:emails];
    }
    
    return;
}

-(void)finishedCallFor:(NSString *)method withData:(NSDictionary *)dict
{
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];

    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&err];
    if ([response objectForKey:@"error"])
    {
        //Something went wrong
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:[response objectForKey:@"error"]];
        [alert runModal];
    }
}

-(NSString *)serializeArray: (NSArray *)array
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
    
    NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    return JSONString;
}

-(NSArray *)deserializeArray: (NSString *)json
{
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    return arr;
}
@end
