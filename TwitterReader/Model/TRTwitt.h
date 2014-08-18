//
//  TRTwitt.h
//  TwitterReader
//
//  Created by Denis Skokov on 17.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TRImage;

@interface TRTwitt : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, strong, readonly) NSString *id;
@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) TRImage *image;
@property (nonatomic, strong, readonly) NSDate *date;
@end
