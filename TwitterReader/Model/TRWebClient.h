//
//  TRWebClient.h
//  TwitterReader
//
//  Created by Denis Skokov on 17.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kWebClientSelectUserNorification;

@class ACAccount;

@interface TRWebClient : NSObject
@property (nonatomic, strong) ACAccount *currentAccount;

+ (TRWebClient *)sharedInstance;
- (void)chooseAccountIfNeed;

- (void)timelineWithMaxId:(NSString *)maxId handler:(void (^)(NSArray *))handler;

@end
