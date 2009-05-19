/* Copyright (c) 2008 Google Inc.
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
//  GDataServiceGooglePhotos.m
//

#define GDATASERVICEGOOGLEPHOTOS_DEFINE_GLOBALS 1
#import "GDataServiceGooglePhotos.h"
#import "GDataEntryPhotoBase.h"
#import "GDataQueryGooglePhotos.h"

// These routines are all simple wrappers around GDataServiceGoogle methods

@implementation GDataServiceGooglePhotos

+ (NSURL *)photoFeedURLForUserID:(NSString *)userID
                         albumID:(NSString *)albumIDorNil
                       albumName:(NSString *)albumNameOrNil
                         photoID:(NSString *)photoIDorNil
                            kind:(NSString *)feedKindOrNil
                          access:(NSString *)accessOrNil {
  
  NSString *albumID = @"";
  if (albumIDorNil) {
    albumID = [NSString stringWithFormat:@"/albumid/%@", 
               [GDataUtilities stringByURLEncodingString:albumIDorNil]]; 
  }
  
  NSString *albumName = @"";
  if (albumNameOrNil && !albumIDorNil) {
    albumName = [NSString stringWithFormat:@"/album/%@", 
                 [GDataUtilities stringByURLEncodingString:albumNameOrNil]];
  }
  
  NSString *photo = @"";
  if (photoIDorNil) {
    photo = [NSString stringWithFormat:@"/photoid/%@", photoIDorNil]; 
  }
  
  // make an array for the kind and access query params, and join the arra items
  // into a query string
  NSString *query = @"";
  NSMutableArray *queryItems = [NSMutableArray array];
  if (feedKindOrNil) {
    feedKindOrNil = [GDataUtilities stringByURLEncodingStringParameter:feedKindOrNil];
    
    NSString *kindStr = [NSString stringWithFormat:@"kind=%@", feedKindOrNil];
    [queryItems addObject:kindStr];
  }
  
  if (accessOrNil) {
    accessOrNil = [GDataUtilities stringByURLEncodingStringParameter:accessOrNil];
    
    NSString *accessStr = [NSString stringWithFormat:@"access=%@", accessOrNil];
    [queryItems addObject:accessStr];
  }
  
  if ([queryItems count]) {
    NSString *queryList = [queryItems componentsJoinedByString:@"&"];
    
    query = [NSString stringWithFormat:@"?%@", queryList];
  }
  
  NSString *root = [self serviceRootURLString];
  
  NSString *template = @"%@feed/api/user/%@%@%@%@%@";
  NSString *urlString = [NSString stringWithFormat:template,
                         root, [GDataUtilities stringByURLEncodingString:userID], 
                         albumID, albumName, photo, query];
  
  return [NSURL URLWithString:urlString];
}

+ (NSURL *)photoContactsFeedURLForUserID:(NSString *)userID {
  
  NSString *root = [self serviceRootURLString];
  
  NSString *template = @"%@feed/api/user/%@/contacts?kind=user";
  
  NSString *urlString = [NSString stringWithFormat:template,
                         root, [GDataUtilities stringByURLEncodingString:userID]];
  
  return [NSURL URLWithString:urlString];
}

- (GDataServiceTicket *)fetchPhotoFeedWithURL:(NSURL *)feedURL
                                     delegate:(id)delegate
                            didFinishSelector:(SEL)finishedSelector
                              didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedFeedWithURL:feedURL 
                                   feedClass:kGDataUseRegisteredClass
                                    delegate:delegate
                           didFinishSelector:finishedSelector
                             didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchPhotoEntryWithURL:(NSURL *)entryURL
                                      delegate:(id)delegate
                             didFinishSelector:(SEL)finishedSelector
                               didFailSelector:(SEL)failedSelector {

  return [self fetchAuthenticatedEntryWithURL:entryURL
                                   entryClass:kGDataUseRegisteredClass
                                     delegate:delegate
                            didFinishSelector:finishedSelector
                              didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchPhotoEntryByInsertingEntry:(GDataEntryPhotoBase *)entryToInsert
                                             forFeedURL:(NSURL *)photoFeedURL
                                               delegate:(id)delegate
                                      didFinishSelector:(SEL)finishedSelector
                                        didFailSelector:(SEL)failedSelector {
  
  if ([entryToInsert namespaces] == nil) {
    [entryToInsert setNamespaces:[GDataEntryPhotoBase photoNamespaces]]; 
  }
  
  return [self fetchAuthenticatedEntryByInsertingEntry:entryToInsert
                                            forFeedURL:photoFeedURL
                                              delegate:delegate
                                     didFinishSelector:finishedSelector
                                       didFailSelector:failedSelector];
  
}

- (GDataServiceTicket *)fetchPhotoEntryByUpdatingEntry:(GDataEntryPhotoBase *)entryToUpdate
                                           forEntryURL:(NSURL *)photoEntryEditURL
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector {
  
  if ([entryToUpdate namespaces] == nil) {
    [entryToUpdate setNamespaces:[GDataEntryPhotoBase photoNamespaces]]; 
  }
  
  return [self fetchAuthenticatedEntryByUpdatingEntry:entryToUpdate
                                          forEntryURL:photoEntryEditURL
                                             delegate:delegate
                                    didFinishSelector:finishedSelector
                                      didFailSelector:failedSelector];
}

- (GDataServiceTicket *)deletePhotoEntry:(GDataEntryPhotoBase *)entryToDelete
                                delegate:(id)delegate
                       didFinishSelector:(SEL)finishedSelector
                         didFailSelector:(SEL)failedSelector {
  
  return [self deleteAuthenticatedEntry:entryToDelete
                               delegate:delegate
                      didFinishSelector:finishedSelector
                        didFailSelector:failedSelector];
}

- (GDataServiceTicket *)deletePhotoResourceURL:(NSURL *)resourceEditURL
                                          ETag:(NSString *)etag
                                      delegate:(id)delegate
                             didFinishSelector:(SEL)finishedSelector
                               didFailSelector:(SEL)failedSelector {
  
  return [self deleteAuthenticatedResourceURL:resourceEditURL
                                         ETag:etag
                                     delegate:delegate
                            didFinishSelector:finishedSelector
                              didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchPhotoQuery:(GDataQueryGooglePhotos *)query
                               delegate:(id)delegate
                      didFinishSelector:(SEL)finishedSelector
                        didFailSelector:(SEL)failedSelector {
  
  return [self fetchPhotoFeedWithURL:[query URL]
                            delegate:delegate
                   didFinishSelector:finishedSelector
                     didFailSelector:failedSelector];
}

- (NSString *)serviceID {
  return @"lh2";
}

+ (NSString *)serviceRootURLString {
  return @"http://photos.googleapis.com/data/"; 
}

+ (NSString *)defaultServiceVersion {
  return kGDataPhotosDefaultServiceVersion;
}

@end

