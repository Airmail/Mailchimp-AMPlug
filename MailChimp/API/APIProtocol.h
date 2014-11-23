//
//  APIProtocol.h
//  MailChimp
//
//  Created by Dean Thomas on 03/11/2014.
//  Copyright (c) 2014 SpikedSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol APIProtocol

-(void)finishedCallFor: (NSString *)method withData: (NSDictionary*)dict;

@end
