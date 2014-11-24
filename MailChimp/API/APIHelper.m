//
//  APIHelper.m
//  MailChimp
//
//  Created by Dean Thomas on 03/11/2014.
//  Copyright (c) 2014 SpikedSoftware. All rights reserved.
//

#import "APIHelper.h"
#import "APIProtocol.h"
@import AppKit;

static NSOperationQueue *operationQueue = nil;

@implementation APIHelper

+(NSOperationQueue *)operationQueue
{
    if (operationQueue == nil)
    {
        operationQueue = [NSOperationQueue new];
        [operationQueue setMaxConcurrentOperationCount:1];
    }
    
    return operationQueue;
}

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
    NSString *apiUrl = [self getUrlWithAPIKey:apiKey forMethod:@"lists/list"];
    NSDictionary *payload = [self basePayloadWithAPIKey:apiKey];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    [request setHTTPBody:jsonData];
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[self operationQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        [delegate finishedCallFor:@"GetLists" withData:dict];
    }];
}

+(void)subscribeEmail:(NSString *)email toList: (NSString *)listId withAPIKey:(NSString *)apiKey andDelegate:(id)delegate
{
    NSMutableDictionary *payload = [self basePayloadWithAPIKey:apiKey];
    [payload setObject:@{ @"email": email } forKey:@"email"];
    [payload setObject:@"false" forKey:@"send_welcome"];
    [payload setObject:listId forKey:@"id"];
    
    NSString *apiUrl = [self getUrlWithAPIKey:apiKey forMethod:@"lists/subscribe"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    [request setHTTPBody:jsonData];
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[self operationQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        [delegate finishedCallFor:@"Subscibe Email" withData:dict];
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
    
    NSString *apiUrl = [self getUrlWithAPIKey:apiKey forMethod:@"lists/batch-subscribe"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    [request setHTTPBody:jsonData];
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[self operationQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        [delegate finishedCallFor:@"Subscibe Email" withData:dict];
    }];
}


@end
