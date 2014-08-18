//
//  TRWebClient.h
//  TwitterReader
//
//  Created by Denis Skokov on 17.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRWebClient : NSObject
@property (nonatomic) BOOL authenticated;
@property (nonatomic) NSError *lastError;

+ (TRWebClient *)sharedInstance;
- (void)auth;
- (void)timelineWithMaxId:(NSString *)maxId handler:(void (^)(NSArray *))handler;

@end
