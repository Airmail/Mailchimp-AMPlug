//
//  MailChimp.h
//  MailChimp
//
//  Created by Dean Thomas on 03/11/2014.
//  Copyright (c) 2014 SpikedSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMPluginFramework/AMPluginFramework.h>
#import "APIProtocol.h"

@interface MailChimp : AMPlugin<APIProtocol>

-(void)setLists: (NSArray *)arr;
-(NSArray *)getLists;

-(void)setAPIKey: (NSString *)apiKey;
-(NSString *)getAPIKey;

-(void)setDefaultListId: (NSString *)id;
-(NSString *)getDefaultListId;

-(BOOL)Save;

@end
