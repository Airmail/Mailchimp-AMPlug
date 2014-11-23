//
//  APIHelper.m
//  MailChimp
//
//  Created by Dean Thomas on 03/11/2014.
//  Copyright (c) 2014 SpikedSoftware. All rights reserved.
//

#import "APIHelper.h"
#import <LRResty.h>
#import "APIProtocol.h"
@import AppKit;


@implementation APIHelper

+(NSString *)getUrlWithAPIKey: (NSString *)apiKey forMethod: (NSString *)method
{
    NSArray *apiKeyParts = [apiKey componentsSeparatedByString:@"-"];
    NSString *getListUrl = [NSString stringWithFormat:@"https://%@.api.mailchimp.com/2.0/%@", [apiKeyParts objectAtIndex:1], method];
    return getListUrl;
}

+(NSMutableDictionary *)basePayloadWithAPIKey: (NSString *)apiKey
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{ @"apikey": apiKey }];
    return dict;
}

+(void)getListsWithAPIKey:(NSString *)apiKey andDelegate:(id)delegate
{
    [[LRResty client] post:[self getUrlWithAPIKey:apiKey forMethod:@"lists/list"] payload:[self basePayloadWithAPIKey:apiKey] headers:nil withBlock:^(LRRestyResponse *response) {
        
        NSError *err;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:response.responseData options:NSJSONReadingMutableContainers error:&err];
        
        [delegate finishedCallFor:@"GetLists" withData:responseDict];
    }];
}

+(void)subscribeEmail:(NSString *)email toList: (NSString *)listId withAPIKey:(NSString *)apiKey andDelegate:(id)delegate
{
    NSMutableDictionary *payload = [self basePayloadWithAPIKey:apiKey];
    [payload setObject:@{ @"email": email } forKey:@"email"];
    [payload setObject:@"false" forKey:@"send_welcome"];
    [payload setObject:listId forKey:@"id"];
    
    [[LRResty client] post:[self getUrlWithAPIKey:apiKey forMethod:@"lists/subscribe"] payload:payload headers:nil withBlock:^(LRRestyResponse *response) {
        NSError *err;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:response.responseData options:NSJSONReadingMutableContainers error:&err];
        
        [delegate finishedCallFor:@"Subscibe Email" withData:responseDict];
    }];
}

+(void)batchSubscribeEmail:(NSArray *)emails toList: (NSString *)listId withAPIKey:(NSString *)apiKey andDelegate:(id)delegate
{
    NSMutableDictionary *payload = [self basePayloadWithAPIKey:apiKey];
    [payload setObject:listId forKey:@"id"];
    
    NSMutableArray *emailsPayload = [NSMutableArray new];
    for (int e = 0; e < emails.count; e ++)
        [emailsPayload addObject:@{ @"email": @{ @"email": [emails objectAtIndex:e] } }];
    [payload setObject:emailsPayload forKey:@"batch"];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&err];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [[LRResty client] post:[self getUrlWithAPIKey:apiKey forMethod:@"lists/batch-subscribe"] payload:json headers:nil withBlock:^(LRRestyResponse *response) {
        NSError *err;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:response.responseData options:NSJSONReadingMutableContainers error:&err];
        
        [delegate finishedCallFor:@"Batch Subscibe Email" withData:responseDict];
    }];
}


@end
