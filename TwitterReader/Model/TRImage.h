//
//  TRImage.h
//  TwitterReader
//
//  Created by Denis Skokov on 17.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRImage : NSObject
- (instancetype)initWithMediaDictionary:(NSDictionary *)dict;

@property (nonatomic, strong, readonly) NSString *url;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, strong) NSData *cachedData;
@end
