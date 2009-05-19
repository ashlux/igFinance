/* Copyright (c) 2007 Google Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

//
//  GDataServiceGoogle.h
//

#import "GDataServiceBase.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEGOOGLE_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataServiceErrorCaptchaRequired _INITIALIZE_AS(@"CaptchaRequired");

// The default user is the authenticated user
_EXTERN NSString* const kGDataServiceDefaultUser _INITIALIZE_AS(@"default");

enum {
  kGDataBadAuthentication = 403
};

@interface NSDictionary (GDataServiceGoogleAdditions) 
// category to get auth info from the callback error's userInfo
- (NSString *)authenticationError;  
- (NSString *)captchaToken;  
- (NSURL *)captchaURL;
@end

@class GDataServiceGoogle;

// GDataServiceTicket is the version of a ticket that supports
// Google authentication
@interface GDataServiceTicket : GDataServiceTicketBase {
  GDataHTTPFetcher *authFetcher_; 
}

- (void)cancelTicket; // stops fetches in progress

- (GDataHTTPFetcher *)authFetcher;
- (void)setAuthFetcher:(GDataHTTPFetcher *)fetcher;
@end

// GDataServiceGoogle is the version of the service class that supports
// Google authentication.
@interface GDataServiceGoogle : GDataServiceBase {
  
  NSString *captchaToken_;
  NSString *captchaAnswer_;
  
  NSString *authToken_;
  NSString *authSubToken_;
  
  NSString *accountType_; // hosted or google
  
  NSString *signInDomain_;
  
  NSString *serviceID_; // typically supplied by the subclass overriding -serviceID
  
  BOOL shouldUseMethodOverrideHeader_;
}

- (GDataServiceTicket *)fetchAuthenticatedFeedWithURL:(NSURL *)feedURL
                                            feedClass:(Class)feedClass
                                             delegate:(id)delegate
                                    didFinishSelector:(SEL)finishedSelector
                                      didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)fetchAuthenticatedEntryWithURL:(NSURL *)entryURL
                                            entryClass:(Class)entryClass
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)fetchAuthenticatedEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                                     forFeedURL:(NSURL *)feedURL
                                                       delegate:(id)delegate
                                              didFinishSelector:(SEL)finishedSelector
                                                didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)fetchAuthenticatedEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                                   forEntryURL:(NSURL *)entryURL
                                                      delegate:(id)delegate
                                             didFinishSelector:(SEL)finishedSelector
                                               didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)deleteAuthenticatedEntry:(GDataEntryBase *)entryToDelete
                                        delegate:(id)delegate
                               didFinishSelector:(SEL)finishedSelector
                                 didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)deleteAuthenticatedResourceURL:(NSURL *)resourceEditURL
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)deleteAuthenticatedResourceURL:(NSURL *)resourceEditURL
                                                  ETag:(NSString *)etag
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)fetchAuthenticatedFeedWithQuery:(GDataQuery *)query
                                              feedClass:(Class)feedClass
                                               delegate:(id)delegate
                                      didFinishSelector:(SEL)finishedSelector
                                        didFailSelector:(SEL)failedSelector;  

- (GDataServiceTicket *)fetchAuthenticatedFeedWithBatchFeed:(GDataFeedBase *)batchFeed
                                            forBatchFeedURL:(NSURL *)feedURL
                                                   delegate:(id)delegate
                                          didFinishSelector:(SEL)finishedSelector
                                            didFailSelector:(SEL)failedSelector;

- (void)setCaptchaToken:(NSString *)captchaToken
          captchaAnswer:(NSString *)captchaAnswer;

- (NSString *)authToken;
- (void)setAuthToken:(NSString *)str;

- (NSString *)authSubToken;
- (void)setAuthSubToken:(NSString *)str;

// default account type is HOSTED_OR_GOOGLE
- (NSString *)accountType;
- (void)setAccountType:(NSString *)str;

// default sign-in domain is www.google.com
- (NSString *)signInDomain;
- (void)setSignInDomain:(NSString *)domain;

// subclasses may add headers to the authentication request
- (NSMutableURLRequest *)authenticationRequestForURL:(NSURL *)url;

// when it's not possible to do http methods other than GET and POST,
// the X-HTTP-Method-Override header can be used in conjunction with POST
// for other commands.  Default for this is NO.
- (BOOL)shouldUseMethodOverrideHeader;
- (void)setShouldUseMethodOverrideHeader:(BOOL)flag;

- (void)setServiceID:(NSString *)str; // call only if not using a subclass
- (NSString *)serviceID; // implemented by subclass, like @"cl" for calendar

  // internal utilities
+ (NSDictionary *)dictionaryWithResponseString:(NSString *)responseString;

@end
