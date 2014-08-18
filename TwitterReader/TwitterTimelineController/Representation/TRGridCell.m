//
//  TRGridCell.m
//  TwitterReader
//
//  Created by Denis Skokov on 17.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import "TRGridCell.h"
#import "TRTwitt.h"
#import "TRImage.h"

static CGFloat const kCellWidth = 150;
static CGFloat const kEdgeInset = 6;

static CGFloat const kAdditionContentHeight = 80;
static CGFloat const kAdditionImageHeight = 8;

@interface TRGridCell(){
    __weak IBOutlet UILabel *_author;
    __weak IBOutlet UIImageView *_image;
    __weak IBOutlet UILabel *_text;
    __weak IBOutlet UILabel *_date;
    __weak IBOutlet NSLayoutConstraint *_imageHeightConstraint;
}

@end

@implementation TRGridCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [_text setFont:[TRGridCell font]];
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
        _imageHeightConstraint.constant = twitt.image.size.height * (kCellWidth - 2*kEdgeInset)/twitt.image.size.width;
    }
    else {
        _imageHeightConstraint.constant = 0;
        [_image setImage:nil];
    }
}

+ (UIFont *)font
{
    return [UIFont systemFontOfSize:14];
}

+ (CGSize)contentSizeForTwittInfo:(TRTwitt *)twitt
{
    CGFloat contentWidth = kCellWidth - 2*kEdgeInset;
    CGFloat height = [twitt.text sizeWithFont:[self font] constrainedToSize:CGSizeMake(contentWidth, INT32_MAX)].height;
    
    if (twitt.image) {
        height += twitt.image.size.height * contentWidth/twitt.image.size.width;
        height += kAdditionImageHeight;
    }
    
    height += kAdditionContentHeight;
    
    return CGSizeMake(kCellWidth, height);
}

@end
