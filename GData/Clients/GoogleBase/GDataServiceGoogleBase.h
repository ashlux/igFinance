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
//  GDataServiceGoogleBase.h
//

#import "GDataServiceGoogle.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEGOOGLEBASE_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataGoogleBaseSnippetsFeed   _INITIALIZE_AS(@"http://base.google.com/base/feeds/snippets");
_EXTERN NSString* const kGDataGoogleBaseItemTypesFeed  _INITIALIZE_AS(@"http://base.google.com/base/feeds/itemtypes");
_EXTERN NSString* const kGDataGoogleBaseAttributesFeed _INITIALIZE_AS(@"http://base.google.com/base/feeds/attributes");
_EXTERN NSString* const kGDataGoogleBaseUserItemsFeed  _INITIALIZE_AS(@"http://www.google.com/base/feeds/items");

@class GDataEntryGoogleBase;
@class GDataQueryGoogleBase;


@interface GDataServiceGoogleBase : GDataServiceGoogle {
  NSString *developerKey_; 
}

- (void)setDeveloperKey:(NSString *)str;

// These routines are all simple wrappers around GDataServiceGoogle methods.

// finishedSelector has signature like:
//   serviceTicket:(GDataServiceTicket *) finishedWithObject:(GDataObject *)object;
// failedSelector has signature like:
//   serviceTicket:(GDataServiceTicket *) failedWithError:(NSError *)error

// finished callback (see above) is passed a GDataFeedGoogleBase
- (GDataServiceTicket *)fetchGoogleBaseFeedWithURL:(NSURL *)feedURL
                                          delegate:(id)delegate
                                 didFinishSelector:(SEL)finishedSelector
                                   didFailSelector:(SEL)failedSelector;  

// finished callback (see above) is passed a GDataEntryGoogleBase
- (GDataServiceTicket *)fetchGoogleBaseEntryWithURL:(NSURL *)entryURL
                                           delegate:(id)delegate
                                  didFinishSelector:(SEL)finishedSelector
                                    didFailSelector:(SEL)failedSelector;  

// finished callback (see above) is passed a GDataEntryGoogleBase
- (GDataServiceTicket *)fetchGoogleBaseEntryByInsertingEntry:(GDataEntryGoogleBase *)entryToInsert
                                                  forFeedURL:(NSURL *)googleBaseFeedURL
                                                    delegate:(id)delegate
                                           didFinishSelector:(SEL)finishedSelector
                                             didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a GDataEntryGoogleBase
- (GDataServiceTicket *)fetchGoogleBaseEntryByUpdatingEntry:(GDataEntryGoogleBase *)entryToUpdate
                                                forEntryURL:(NSURL *)googleBaseEntryEditURL
                                                   delegate:(id)delegate
                                          didFinishSelector:(SEL)finishedSelector
                                            didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a nil object
- (GDataServiceTicket *)deleteGoogleBaseEntry:(GDataEntryGoogleBase *)entryToDelete
                                     delegate:(id)delegate
                            didFinishSelector:(SEL)finishedSelector
                              didFailSelector:(SEL)failedSelector;
  
// finished callback (see above) is passed a nil object
- (GDataServiceTicket *)deleteGoogleBaseResourceURL:(NSURL *)resourceEditURL
                                               ETag:(NSString *)etag
                                           delegate:(id)delegate
                                  didFinishSelector:(SEL)finishedSelector
                                    didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a GDataFeedGoogleBase
- (GDataServiceTicket *)fetchGoogleBaseQuery:(GDataQueryGoogleBase *)query
                                    delegate:(id)delegate
                           didFinishSelector:(SEL)finishedSelector
                             didFailSelector:(SEL)failedSelector;  

// finished callback (see above) is passed a batch result feed
//
// status may also be present inside the individual entries
// as GDataBatchStatus and GDataBatchInterrupted elements
- (GDataServiceTicket *)fetchGoogleBaseFeedWithBatchFeed:(GDataFeedBase *)batchFeed
                                         forBatchFeedURL:(NSURL *)feedURL
                                                delegate:(id)delegate
                                       didFinishSelector:(SEL)finishedSelector
                                         didFailSelector:(SEL)failedSelector;
@end
