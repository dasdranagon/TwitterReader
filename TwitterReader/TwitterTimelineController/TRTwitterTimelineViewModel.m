//
//  TRTwitterTimelineViewModel.m
//  TwitterReader
//
//  Created by Denis Skokov on 16.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import "TRTwitterTimelineViewModel.h"
#import "TRWebClient.h"
#import "TRTwitt.h"
#import "TRImage.h"

@interface TRTwitterTimelineViewModel(){
    TRWebClient *_webClient;
}

@end

@implementation TRTwitterTimelineViewModel

- (instancetype)initWithWebClient:(TRWebClient *)webClient
{
    self = [super init];
    if (self) {
        _webClient = webClient;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        [_webClient addObserver:self
                     forKeyPath:NSStringFromSelector(@selector(authenticated))
                        options:NSKeyValueObservingOptionNew
                        context:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [_webClient removeObserver:self forKeyPath:NSStringFromSelector(@selector(authenticated))];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(authenticated))]) {
        [self update];
    }
}

- (void)activate
{
    if (_webClient.authenticated) {
        [self update];
    }
}

- (void)more
{
    if (!_processing) {
        self.processing = YES;
        __weak TRTwitterTimelineViewModel *weakSelf = self;
        [_webClient timelineWithMaxId:[[self.twitts lastObject] id] handler:^(NSArray *list) {
            __strong TRTwitterTimelineViewModel *strongSelf = weakSelf;
            
            NSArray *newTwitts = [strongSelf twitsFromArray:list];
            if ([newTwitts count]) {
                strongSelf.twitts = [strongSelf.twitts arrayByAddingObjectsFromArray:newTwitts];
            }
            strongSelf.processing = NO;
        }];
    }
}

- (void)update
{
    if (!_processing) {
        self.processing = YES;
        __weak TRTwitterTimelineViewModel *weakSelf = self;
        [_webClient timelineWithMaxId:nil handler:^(NSArray *list) {
            __strong TRTwitterTimelineViewModel *strongSelf = weakSelf;
            
            NSArray *newTwitts = [strongSelf twitsFromArray:list];
            
            if ([newTwitts count]) {
                strongSelf.twitts = newTwitts;
            }
            
            strongSelf.processing = NO;
        }];
    }
}

- (NSArray *)twitsFromArray:(NSArray *)array
{
    NSMutableArray *twitts = [NSMutableArray new];
    [array enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        TRTwitt *twitt = [[TRTwitt alloc] initWithDictionary:dict];
        [twitts addObject:twitt];
        
        NSURLSession *session = [NSURLSession sharedSession];
        __weak TRTwitterTimelineViewModel *weakSelf = self;
        [[session dataTaskWithURL:[NSURL URLWithString:twitt.image.url]
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    __strong TRTwitterTimelineViewModel *strongSelf = weakSelf;
                    if (!error) {
                        twitt.image.cachedData = data;
                        [strongSelf.delegate timelineViewModel:strongSelf updatedItemAtIndex:idx];
                    }
                }] resume];
    }];

    return [twitts copy];
}

#pragma mark -- recive memory warning

- (void)didReceiveMemoryWarning:(NSNotification *)notify
{
    self.twitts = nil;
    [self update];
}

@end
