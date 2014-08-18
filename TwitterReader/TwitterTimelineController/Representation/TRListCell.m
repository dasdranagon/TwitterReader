//
//  TRListCell.m
//  TwitterReader
//
//  Created by Denis Skokov on 17.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import "TRListCell.h"
#import "TRTwitt.h"
#import "TRImage.h"

static CGFloat const kMaxContentWidth = 300;
static CGFloat const kAdditionContentHeight = 70;
static CGFloat const kAdditionImageHeight = 8;

@interface TRListCell(){
    __weak IBOutlet UILabel *_text;
    __weak IBOutlet UIImageView *_image;
    __weak IBOutlet UILabel *_author;
    __weak IBOutlet UILabel *_date;
}

@end

@implementation TRListCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [_text setFont:[TRListCell font]];
}

- (void)setTwittInfo:(TRTwitt *)twitt
{
    [_text setText:twitt.text];
    [_author setText:twitt.username];
    
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy.MM.dd mm:ss"];
    });
    [_date setText:[formatter stringFromDate:twitt.date]];
    
    if (twitt.image.cachedData) {
        [_image setImage:[UIImage imageWithData:twitt.image.cachedData]];
    }
    else {
        [_image setImage:nil];
    }
}

+ (UIFont *)font
{
    return [UIFont systemFontOfSize:17];
}

+ (CGSize)contentSizeForTwittInfo:(TRTwitt *)twitt
{
    CGFloat height = [twitt.text sizeWithFont:[self font] constrainedToSize:CGSizeMake(kMaxContentWidth, 1000)].height;
    
    if (twitt.image) {
        height += twitt.image.size.height * kMaxContentWidth/twitt.image.size.width;
        height += kAdditionImageHeight;
    }

    height += kAdditionContentHeight;
    
    return CGSizeMake(kMaxContentWidth, height);
}

@end
