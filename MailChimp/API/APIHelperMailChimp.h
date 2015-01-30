//
//  APIHelper.h
//  MailChimp
//
//  Created by Dean Thomas on 03/11/2014.
//  Copyright (c) 2014 SpikedSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIHelperMailChimp : NSObject

+(void)getListsWithAPIKey: (NSString *)apiKey andDelegate: (id)delegate;
+(void)subscribeEmail: (NSString *)email toList: (NSString *)listId withAPIKey: (NSString *)apiKey andDelegate: (id)delegate;
+(void)batchSubscribeEmail:(NSArray *)emails toList: (NSString *)listId withAPIKey:(NSString *)apiKey andDelegate:(id)delegate;

@end
