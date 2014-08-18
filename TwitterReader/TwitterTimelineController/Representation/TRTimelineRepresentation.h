//
//  TRTimelineRepresentation.h
//  TwitterReader
//
//  Created by Denis Skokov on 17.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TRTwitt;

typedef NS_ENUM(NSInteger, TRTimelineRepresentationSignal)
{
    TRTimelineRepresentationSignalUpdate,
    TRTimelineRepresentationSignalLoadMore,
};

@protocol TRTimelineRepresentationDelegate;

@protocol TRTimelineRepresentation <NSObject>
- (UIView *)view;
- (void)setDelegate:(id<TRTimelineRepresentationDelegate>)delegate;
- (void)updateList;
- (void)updateItemAtIndex:(NSInteger)idx;
- (void)updateProgressing:(BOOL)progress;

@end

@protocol TRTimelineRepresentationDelegate  <NSObject>
- (NSInteger)twittsCount;
- (TRTwitt *)twittAtIndex:(NSInteger)idx;

- (void)representation:(id<TRTimelineRepresentation>)representation signal:(TRTimelineRepresentationSignal)signal;
@end