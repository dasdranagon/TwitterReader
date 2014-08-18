//
//  TRImage.m
//  TwitterReader
//
//  Created by Denis Skokov on 17.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import "TRImage.h"

@implementation TRImage

- (instancetype)initWithMediaDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _url = dict[@"media_url"];
        
        NSDictionary *sizes = dict[@"sizes"];
        if (sizes) {
            NSDictionary *small = sizes[@"small"];
            if (small) {
                _size = CGSizeMake([small[@"w"] floatValue], [small[@"h"] floatValue]);
            }
        }
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@> img:%@ sz:%@", [self class], _url, [NSValue valueWithCGSize:_size]];
}

@end
