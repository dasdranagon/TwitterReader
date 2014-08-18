//
//  TRWebClient.m
//  TwitterReader
//
//  Created by Denis Skokov on 17.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import "TRWebClient.h"

static NSString * const apiKey = @"NvimLbpC4AHQjBnEtcXlRw";
static NSString * const apiSecret = @"6a8J5mP2NMU7PCNcC7ta0ltFZyXJxsxKAdcEdc72Cg";

@interface TRWebClient(){
    NSString *_accessTocken;
}

@end

@implementation TRWebClient

+ (TRWebClient *)sharedInstance
{
    static TRWebClient *webClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        webClient = [[TRWebClient alloc] init];
    });
    
    return webClient;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self auth];
    }
    
    return self;
}

- (void) auth
{
    NSString *bearerToken = [[NSString stringWithFormat:@"%@:%@", apiKey, apiSecret] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *bearerTokenBase64 = [[bearerToken dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.twitter.com/oauth2/token"]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:[@"Basic " stringByAppendingString:bearerTokenBase64] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[@"grant_type=client_credentials" dataUsingEncoding:NSUTF8StringEncoding]];
    
    __weak TRWebClient *weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *responseData, NSURLResponse *response, NSError *error) {
        __strong TRWebClient *strongSelf = weakSelf;
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        if ([data isKindOfClass:[NSDictionary class]]) {
            strongSelf->_accessTocken = data[@"access_token"];
            strongSelf.authenticated = strongSelf->_accessTocken != nil;
        }
    }] resume];
}

- (void)timelineWithMaxId:(NSString *)maxId handler:(void (^)(NSArray *))handler
{
    if (!_authenticated) {
        handler (nil);
        return;
    }
    
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json?include_rts=0"];
    
    if (maxId) {
        [urlString appendFormat:@"&max_id=%lld", [maxId longLongValue]-1];
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:[@"Bearer " stringByAppendingString:_accessTocken] forHTTPHeaderField:@"Authorization"];
    
    __weak TRWebClient *weakSelf = self;
    
    NSLog(@"%@  : %@", request, request.allHTTPHeaderFields);
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *responseData, NSURLResponse *response, NSError *error) {
                                         __strong TRWebClient *strongSelf = weakSelf;
                                         strongSelf.lastError = error;
                                         id data = nil;
                                         if (responseData) {
                                             NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                                             if (statusCode >= 200 && statusCode < 300) {
                                                 NSError *jsonError;
                                                 data = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                        options:NSJSONReadingAllowFragments
                                                                                          error:&jsonError];
                                                 NSLog(@"%@", data);
                                                 strongSelf.lastError = jsonError;
                                             }
                                         }
                                         NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:responseData
                                                                                      options:NSJSONReadingAllowFragments
                                                                                        error:nil]);
                                         handler (data);
    }] resume];
}

@end
