//
//  TRWebClient.m
//  TwitterReader
//
//  Created by Denis Skokov on 17.08.14.
//  Copyright (c) 2014 Denis Skokov. All rights reserved.
//

#import "TRWebClient.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

NSString * const kWebClientSelectUserNorification = @"kWebClientSelectUserNorification";

@interface TRWebClient() <UIActionSheetDelegate>{
    ACAccountStore *_accountStore;
    
    BOOL _selectUserSheetOnScreen;
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
        _accountStore = [[ACAccountStore alloc] init];
    }
    
    return self;
}

- (void)timelineWithMaxId:(NSString *)maxId handler:(void (^)(NSArray *))handler
{
    if (!_currentAccount) {
        return;
    }
    
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json?include_rts=0"];
    
    if (maxId) {
        [urlString appendFormat:@"&max_id=%lld", [maxId longLongValue]-1];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];

    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:url
                                               parameters:nil];
    [request setAccount:_currentAccount];
    
    __weak TRWebClient *weakSelf = self;
    [request performRequestWithHandler:^(NSData *responseData,
                                         NSHTTPURLResponse *urlResponse,
                                         NSError *error) {
        __strong TRWebClient *strongSelf = weakSelf;
        id data = nil;
        if (responseData) {
            if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                NSError *error;
                data = [NSJSONSerialization JSONObjectWithData:responseData
                                                                             options:NSJSONReadingAllowFragments
                                                            error:&error];
                if (!data) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf showAlert:[error localizedDescription]];
                    });
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf showAlert:[NSString stringWithFormat:@"The response status code is %d", urlResponse.statusCode]];
                });
            }
        }
        handler (data);
    }];

}

- (BOOL)hasAccess
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)chooseAccountIfNeed
{
    if ( [self hasAccess] ) {
        if (_currentAccount == nil) {
            [self changeAccount];
        }
    }
    else {
        self.currentAccount = nil;
        [self showAlert:@"you are not logged in\nplease choose twitter in settings and log in in your twitter account"];
    }
}

- (void)changeAccount
{
    ACAccountType *twitterAccountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    __weak TRWebClient *weakSelf = self;
    [_accountStore requestAccessToAccountsWithType:twitterAccountType
                                           options:nil
                                        completion:^(BOOL granted, NSError *error) {
                                            __strong TRWebClient *strongSelf = weakSelf;
                                            if (granted) {
                                                NSArray *twitterAccounts = [_accountStore accountsWithAccountType:twitterAccountType];
                                                if ((twitterAccounts.count > 1) && !_selectUserSheetOnScreen) {
                                                    _selectUserSheetOnScreen = YES;
                                                    
                                                    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
                                                    actionSheet.delegate = strongSelf;
                                                    [actionSheet setTitle:@"Choose your username"];
                                                    
                                                    [twitterAccounts enumerateObjectsUsingBlock:^(ACAccount *acc, NSUInteger idx, BOOL *stop) {
                                                        [actionSheet addButtonWithTitle:acc.username];
                                                    }];
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
                                                    });
                                                    
                                                } else {
                                                    strongSelf.currentAccount = [twitterAccounts lastObject];
                                                }
                                            }
                                            else {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [strongSelf showAlert:[error localizedDescription]];
                                                });
                                            }
                                        }];
}

- (void)showAlert:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:nil
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

- (void)setCurrentAccount:(ACAccount *)currentAccount
{
    _currentAccount = currentAccount;
    [[NSNotificationCenter defaultCenter] postNotificationName:kWebClientSelectUserNorification object:self userInfo:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _selectUserSheetOnScreen = NO;
    NSArray *twitterAccounts = [_accountStore accountsWithAccountType:[_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]];
    self.currentAccount = [twitterAccounts objectAtIndex:buttonIndex];
}

@end
