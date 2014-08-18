//
//  TRTwitt.m
//  TwitterReader
//
//  Created by Denis Skokov on 17.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import "TRTwitt.h"
#import "TRImage.h"

@implementation TRTwitt

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _id = dictionary[@"id"];
        _text = dictionary[@"text"];
        
        NSDictionary *user = dictionary[@"user"];
        if (user) {
            _username = user[@"name"];
        }
        
        NSDictionary *entities = dictionary[@"entities"];
        if (entities) {
            NSArray *medias = entities[@"media"];
            [medias enumerateObjectsWithOptions:NSEnumerationConcurrent
                                     usingBlock:^(NSDictionary *media, NSUInteger idx, BOOL *stop) {
                                         if ([media[@"type"] isEqualToString:@"photo"]) {
                                             _image = [[TRImage alloc] initWithMediaDictionary:media];
                                             *stop = YES;
                                         }
                                     }];
        }
        
        NSString *strDate = dictionary[@"created_at"];
        if (strDate) {
            static NSDateFormatter *formater = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                formater = [[NSDateFormatter alloc] init];
                [formater setDateFormat:@"EEE LLL d HH:mm:ss Z y"];
            });
            
            _date = [formater dateFromString:strDate];
        }
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@> id:%@ username:%@ date:%@ text:%@  img:%@", [self class], _id, _username, _date, _text, _image];
}

@end
