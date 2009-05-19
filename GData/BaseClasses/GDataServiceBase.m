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
//  GDataServiceBase.m
//

#import <TargetConditionals.h>
#if TARGET_OS_MAC
#include <sys/utsname.h>
#endif

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#define GDATASERVICEBASE_DEFINE_GLOBALS 1
#import "GDataServiceBase.h"
#import "GDataProgressMonitorInputStream.h"
#import "GDataServerError.h"
#import "GDataFramework.h"

static NSString *const kXMLErrorContentType = @"application/vnd.google.gdata.error+xml";

static NSString* const kFetcherDelegateKey = @"_delegate";
static NSString* const kFetcherObjectClassKey = @"_objectClass";
static NSString* const kFetcherFinishedSelectorKey = @"_finishedSelector";
static NSString* const kFetcherFailedSelectorKey = @"_failedSelector";
static NSString* const kFetcherTicketKey = @"_ticket";
static NSString* const kFetcherStreamDataKey = @"_streamData";

NSString* const kFetcherRetryInvocationKey = @"_retryInvocation";

const NSUInteger kMaxNumberOfNextLinksFollowed = 25;

// XorPlainMutableData is a simple way to keep passwords held in heap objects
// from being visible as plain-text
static void XorPlainMutableData(NSMutableData *mutable) {
  
  // this helps avoid storing passwords on the heap in plaintext
  const UInt8 theXORValue = 0x95; // 0x95 = 0xb10010101
  
  UInt8 *dataPtr = [mutable mutableBytes];
  NSUInteger length = [mutable length];
  
  for (NSUInteger idx = 0; idx < length; idx++) {
    dataPtr[idx] ^= theXORValue;
  }
}


@interface GDataServiceBase (PrivateMethods)

- (BOOL)fetchNextFeedWithURL:(NSURL *)nextFeedURL
                    delegate:(id)delegate
         didFinishedSelector:(SEL)finishedSelector
             didFailSelector:(SEL)failedSelector
                      ticket:(GDataServiceTicketBase *)ticket;

- (NSDictionary *)userInfoForErrorResponseData:(NSData *)data
                                   contentType:(NSString *)contentType;
@end

@implementation GDataServiceBase

- (id)init {
  self = [super init];
  if (self) {
    fetchHistory_ = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)dealloc {
  [serviceVersion_ release];
  [userAgent_ release];
  [fetchHistory_ release];
  [runLoopModes_ release];
  
  [username_ release];
  [password_ release];
  
  [serviceUserData_ release];
  [serviceProperties_ release];
  [serviceSurrogates_ release];
  
  [super dealloc];
}

- (NSString *)systemVersionString {

  NSString *systemString = @"";

#ifndef GDATA_FOUNDATION_ONLY
  // Mac build
  SInt32 systemMajor = 0, systemMinor = 0, systemRelease = 0;
  (void) Gestalt(gestaltSystemVersionMajor, &systemMajor);
  (void) Gestalt(gestaltSystemVersionMinor, &systemMinor);
  (void) Gestalt(gestaltSystemVersionBugFix, &systemRelease);

  systemString = [NSString stringWithFormat:@"MacOSX/%d.%d.%d",
    systemMajor, systemMinor, systemRelease];

#elif GDATA_IPHONE && TARGET_OS_IPHONE
  // compiling against the iPhone SDK

  static NSString *savedSystemString = nil;

  @synchronized([GDataServiceBase class]) {

    if (savedSystemString == nil) {
      // avoid the slowness of calling currentDevice repeatedly on the iPhone
      UIDevice* currentDevice = [UIDevice currentDevice];

      NSString *rawModel = [currentDevice model];
      NSString *model = [GDataUtilities userAgentStringForString:rawModel];

      NSString *systemVersion = [currentDevice systemVersion];

      savedSystemString = [[NSString alloc] initWithFormat:@"%@/%@",
                           model, systemVersion]; // "iPod_Touch/2.2"
    }
  }
  systemString = savedSystemString;

#elif GDATA_IPHONE
  // GDATA_IPHONE defined but compiling against the Mac SDK
  systemString = @"iPhone/x.x";

#elif defined(_SYS_UTSNAME_H)
  // Foundation-only build
  struct utsname unameRecord;
  uname(&unameRecord);

  systemString = [NSString stringWithFormat:@"%s/%s",
                  unameRecord.sysname, unameRecord.release]; // "Darwin/8.11.1"
#endif

  return systemString;
}

- (NSString *)requestUserAgent {

  NSString *userAgent = [self userAgent];

  if ([userAgent length] == 0 || [userAgent hasPrefix:@"MyCompany-"]) {

    // missing explicit user-agent; use the process name and bundle ID
    userAgent = [self defaultApplicationIdentifier];

    // remind developer to call the service object's setUserAgent:
    // method
    NSLog(@"gdata developer user-agent unspecified");
  }

  NSString *requestUserAgent = userAgent;

  // if the user agent already specifies the library version, we'll
  // use it verbatim in the request
  NSString *libraryString = @"GData-ObjectiveC";
  NSRange libRange = [userAgent rangeOfString:libraryString
                                      options:NSCaseInsensitiveSearch];
  if (libRange.location == NSNotFound) {
    // the user agent doesn't specify the client library, so append that
    // information, and the system version
    long major, minor, release;
    NSString *libVersionString;
    GDataFrameworkVersion(&major, &minor, &release);

    // most library releases will have a release value of zero
    if (release != 0) {
      libVersionString = [NSString stringWithFormat:@"%d.%d.%d",
        major, minor, release];
    } else {
      libVersionString = [NSString stringWithFormat:@"%d.%d", major, minor];
    }

    NSString *systemString = [self systemVersionString];

    // Google servers look for gzip in the user agent before sending gzip-
    // encoded responses.  See Service.java
    requestUserAgent = [NSString stringWithFormat:@"%@ %@/%@ %@ (gzip)",
      userAgent, libraryString, libVersionString, systemString];
  }
  return requestUserAgent;
}

- (NSMutableURLRequest *)requestForURL:(NSURL *)url 
                                  ETag:(NSString *)etag
                            httpMethod:(NSString *)httpMethod {
  
  // subclasses may add headers to this
  NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                           timeoutInterval:60] autorelease];
  
  NSString *requestUserAgent = [self requestUserAgent];
  [request setValue:requestUserAgent forHTTPHeaderField:@"User-Agent"];

  NSString *serviceVersion = [self serviceVersion];
  if ([serviceVersion length] > 0) {

    // only add a version header if the URL lacks a v= version parameter
    NSString *queryString = [url query];
    if  (queryString == nil
         || ([queryString rangeOfString:@"&v="].location == NSNotFound
             && ![queryString hasPrefix:@"v="])) {

      [request setValue:serviceVersion forHTTPHeaderField:@"GData-Version"];
    }
  }
  
  if ([httpMethod length] > 0) {
    [request setHTTPMethod:httpMethod];
  }
  
  if ([etag length] > 0) {
    
    // it's rather unexpected for an etagged object to be provided for a GET, 
    // but we'll check for an etag anyway, similar to HttpGDataRequest.java,
    // and if present use it to request only an unchanged resource
    
    BOOL isDoingHTTPGet = (httpMethod == nil 
               || [httpMethod caseInsensitiveCompare:@"GET"] == NSOrderedSame);
    
    if (isDoingHTTPGet) {
      
      // set the etag header, even if weak, indicating we don't want 
      // another copy of the resource if it's the same as the object
      [request setValue:etag forHTTPHeaderField:@"If-None-Match"]; 
      
    } else {
      
      // if we're doing PUT or DELETE, set the etag header indicating
      // we only want to update the resource if our copy matches the current
      // one (unless the etag is weak and so shouldn't be a constraint at all)
      BOOL isWeakETag = [etag hasPrefix:@"W/"];
      
      BOOL isDoingPutOrDelete = 
        [httpMethod caseInsensitiveCompare:@"PUT"] == NSOrderedSame
        || [httpMethod caseInsensitiveCompare:@"DELETE"] == NSOrderedSame;
      
      if (isDoingPutOrDelete && !isWeakETag) {
        [request setValue:etag forHTTPHeaderField:@"If-Match"]; 
      }
    }
  }
  
  return request;
}


// objectRequestForURL returns an NSMutableURLRequest for a GData object as XML
//
// the object is the object being sent to the server, or nil;
// the http method may be nil for get, or POST, PUT, DELETE

- (NSMutableURLRequest *)objectRequestForURL:(NSURL *)url 
                                      object:(GDataObject *)object
                                        ETag:(NSString *)etag
                                  httpMethod:(NSString *)httpMethod {
  
  // if the object being sent has an etag, add it to the request header to
  // avoid retrieving a duplicate or to avoid writing over an updated
  // version of the resource on the server
  //
  // Typically, delete requests will provide an explicit ETag parameter, and
  // other requests will have the ETag carried inside the object being updated
  
  if (etag == nil) {
    SEL selEtag = @selector(ETag);
    if ([object respondsToSelector:selEtag]) {
      
      etag = [object performSelector:selEtag];
    }
  }

  NSMutableURLRequest *request = [self requestForURL:url
                                                ETag:etag
                                          httpMethod:httpMethod];
  
  [request setValue:@"application/atom+xml, text/xml" forHTTPHeaderField:@"Accept"];
  
  [request setValue:@"application/atom+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"]; // header is authoritative for character set issues.
  
  [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    
  return request;
}


#pragma mark -

- (GDataServiceTicketBase *)fetchObjectWithURL:(NSURL *)feedURL
                                   objectClass:(Class)objectClass
                                  objectToPost:(GDataObject *)objectToPost
                                          ETag:(NSString *)etag
                                    httpMethod:(NSString *)httpMethod
                                      delegate:(id)delegate
                             didFinishSelector:(SEL)finishedSelector
                               didFailSelector:(SEL)failedSelector
                          retryInvocationValue:(NSValue *)retryInvocationValue
                                        ticket:(GDataServiceTicketBase *)ticket {
  
  AssertSelectorNilOrImplementedWithArguments(delegate, finishedSelector, @encode(GDataServiceTicketBase *), @encode(GDataObject *), 0);
  AssertSelectorNilOrImplementedWithArguments(delegate, failedSelector, @encode(GDataServiceTicketBase *), @encode(NSError *), 0);

  // if no URL was supplied, treat this as if the fetch failed (below)
  // and immediately return a nil ticket, skipping the callbacks
  //
  // this might be considered normal (say, updating a read-only entry
  // that lacks an edit link) though higher-level calls may assert or
  // returns errors depending on the specific usage
  if (feedURL == nil) return nil;
  
  NSMutableURLRequest *request = [self objectRequestForURL:feedURL
                                                    object:objectToPost
                                                      ETag:etag
                                                httpMethod:httpMethod];
  
  // we need to create a ticket unless one was created earlier (like during
  // authentication)
  if (!ticket) {
    ticket = [GDataServiceTicketBase ticketForService:self];
  }
  
  AssertSelectorNilOrImplementedWithArguments(delegate, [ticket uploadProgressSelector],
      @encode(GDataProgressMonitorInputStream *), @encode(unsigned long long), 
      @encode(unsigned long long), 0);
  AssertSelectorNilOrImplementedWithArguments(delegate, [ticket retrySelector],
      @encode(GDataServiceTicketBase *),@encode(BOOL), @encode(NSError *), 0);
  
  NSInputStream *uploadStream = nil;
  NSData *uploadData = nil;
  NSData *dataToRetain = nil;
  
  if (objectToPost) {

    [ticket setPostedObject:objectToPost];

    // An upload object may provide a custom input stream, such as for 
    // multi-part MIME or media uploads.  If it lacks a custom stream, 
    // we'll make a stream from the XML data of the object.

    NSInputStream *contentInputStream = nil;
    unsigned long long contentLength = 0;
    NSDictionary *contentHeaders = nil;
    
    SEL progressSelector = [ticket uploadProgressSelector];

    if ([objectToPost generateContentInputStream:&contentInputStream
                                          length:&contentLength
                                         headers:&contentHeaders]) {
      // there is a stream
      
      // add the content-specific headers, if any
      NSEnumerator *keyEnum = [contentHeaders keyEnumerator];
      NSString *key;
      while ((key = [keyEnum nextObject]) != nil) {
        NSString *value = [contentHeaders objectForKey:key];
        [request setValue:value forHTTPHeaderField:key];
      }
      
    } else {
      
      NSData* xmlData = [[objectToPost XMLDocument] XMLData];
      contentLength = [xmlData length];
      
      if (progressSelector == nil) {
        // there is no progress selector; we can post plain NSData, which
        // is simpler because it survives http redirects
        uploadData = xmlData;
        
      } else {
        // there is a progress selector, so we need to be posting a stream
        //
        // we'll make a default input stream from the XML data
        contentInputStream = [NSInputStream inputStreamWithData:xmlData];
        
        // NSInputStream fails to retain or copy its data in 10.4, so we will
        // retain it in the callback dictionary.  We won't use the data in the
        // callbacks at all, but retaining it will ensure it's still around until
        // the upload completes.
        //
        // If it weren't for this bug in NSInputStream, we could just have
        // GDataObject's -contentInputStream method create the input stream for
        // us, so this service class wouldn't ever need to call XMLElement.
        dataToRetain = xmlData; 
      }
    }

    uploadStream = contentInputStream;
    if (progressSelector != nil) {
      
      // the caller is monitoring the upload progress, so wrap the input stream
      // with an input stream that will call back to the delegate's progress
      // selector
      GDataProgressMonitorInputStream* monitoredInputStream;
      
      monitoredInputStream = [GDataProgressMonitorInputStream inputStreamWithStream:contentInputStream
                                                                             length:contentLength];
      [monitoredInputStream setDelegate:nil];
      [monitoredInputStream setMonitorDelegate:delegate];
      [monitoredInputStream setMonitorSelector:progressSelector];
      [monitoredInputStream setMonitorSource:ticket];
      
      uploadStream = monitoredInputStream;
    }
    
    NSNumber* num = [NSNumber numberWithUnsignedLongLong:contentLength];
    [request setValue:[num stringValue] forHTTPHeaderField:@"Content-Length"];
  }
  
  GDataHTTPFetcher* fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];

  [fetcher setRunLoopModes:[self runLoopModes]];
  
  if (uploadStream) {
    [fetcher setPostStream:uploadStream]; 
  } else if (uploadData) {
    [fetcher setPostData:uploadData]; 
  }
  
  // add cookie and last-modified-since history
  [fetcher setFetchHistory:fetchHistory_];
  
  // when the server gives us a "Not Modified" error, have the fetcher
  // just pass us the cached data from the previous call, if any
  [fetcher setShouldCacheDatedData:[self shouldCacheDatedData]];
  
  // copy the service's retry settings into the ticket
  [fetcher setIsRetryEnabled:[ticket isRetryEnabled]];
  [fetcher setMaxRetryInterval:[ticket maxRetryInterval]];
  
  if ([ticket retrySelector]) {
    [fetcher setRetrySelector:@selector(objectFetcher:willRetry:forError:)];
  }
  
  // remember the object fetcher in the ticket
  [ticket setObjectFetcher:fetcher];
  [ticket setCurrentFetcher:fetcher];
    
  // add parameters used by the callbacks
  //
  // we want to add the invocation itself, not the value wrapper of it,
  // to ensure the invocation is retained until the callback completes

  [fetcher setProperty:objectClass forKey:kFetcherObjectClassKey];

  [fetcher setProperty:delegate forKey:kFetcherDelegateKey];

  [fetcher setProperty:NSStringFromSelector(finishedSelector)
                forKey:kFetcherFinishedSelectorKey];

  [fetcher setProperty:NSStringFromSelector(failedSelector)
                forKey:kFetcherFailedSelectorKey];

  NSInvocation *retryInvocation = [retryInvocationValue nonretainedObjectValue];
  [fetcher setProperty:retryInvocation
                forKey:kFetcherRetryInvocationKey];

  [fetcher setProperty:ticket
                forKey:kFetcherTicketKey];

  // the stream data is retained only because of an NSInputStream bug in 
  // 10.4, as described above
  [fetcher setProperty:dataToRetain forKey:kFetcherStreamDataKey];

  // add username/password
  [self addAuthenticationToFetcher:fetcher];
  
  // failed fetches call the failure selector, which will delete the ticket
  BOOL didFetch = [fetcher beginFetchWithDelegate:self
                                didFinishSelector:@selector(objectFetcher:finishedWithData:)
                        didFailWithStatusSelector:@selector(objectFetcher:failedWithStatus:data:)
                         didFailWithErrorSelector:@selector(objectFetcher:failedWithNetworkError:)];
  
  // If something weird happens and the networking callbacks have been called
  // already synchronously, we don't want to return the ticket since the caller 
  // will never know when to stop retaining it, so we'll make sure the
  // success/failure callbacks have not yet been called by checking the
  // ticket
  if (!didFetch || [ticket hasCalledCallback]) {
    return nil; 
  }
    
  return ticket;
}

- (void)objectFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {
  
  // unpack the callback parameters
  id delegate = [fetcher propertyForKey:kFetcherDelegateKey];
  Class objectClass = [fetcher propertyForKey:kFetcherObjectClassKey];
  SEL finishedSelector = NSSelectorFromString([fetcher propertyForKey:kFetcherFinishedSelectorKey]);
  SEL failedSelector = NSSelectorFromString([fetcher propertyForKey:kFetcherFailedSelectorKey]);
  
  GDataServiceTicketBase *ticket = [fetcher propertyForKey:kFetcherTicketKey];
  
  NSError *error = nil;
  
  GDataObject* object = nil;
  NSUInteger dataLength = [data length];
  
  // create the object returned by the service, if any
  if (dataLength > 0) {
    
#if GDATA_LOG_PERFORMANCE
    UnsignedWide msecs1, msecs2;
    Microseconds(&msecs1);
#endif
    
    NSXMLDocument *xmlDocument = [[[NSXMLDocument alloc] initWithData:data
                                                              options:0
                                                                error:&error] autorelease];
    if (xmlDocument) {
      
      NSXMLElement* root = [xmlDocument rootElement];
      
      if (!objectClass) {
        objectClass = [GDataObject objectClassForXMLElement:root]; 
      }
      
      // see if the top-level class for the XML is listed in the surrogates; 
      // if so, instantiate the surrogate class instead
      NSDictionary *surrogates = [ticket surrogates];
      Class baseSurrogate = [surrogates objectForKey:objectClass];
      if (baseSurrogate) {
        objectClass = baseSurrogate; 
      }

      // use the actual service version indicated by the response headers
      NSDictionary *responseHeaders = [fetcher responseHeaders];
      NSString *serviceVersion = [responseHeaders objectForKey:@"Gdata-Version"];

      // feeds may optionally be instantiated without unknown elements tracked
      //
      // we only ever want to fetch feeds and discard the unknown XML, never
      // entries
      BOOL shouldIgnoreUnknowns = (shouldServiceFeedsIgnoreUnknowns_
                      && [objectClass isSubclassOfClass:[GDataFeedBase class]]);

      object = [[[objectClass alloc] initWithXMLElement:root
                                                 parent:nil
                                         serviceVersion:serviceVersion
                                             surrogates:surrogates
                                   shouldIgnoreUnknowns:shouldIgnoreUnknowns] autorelease];

      // we're done parsing; the extension declarations won't be needed again
      [object clearExtensionDeclarationsCache];

#if GDATA_USES_LIBXML
      // retain the document so that pointers to internal nodes remain valid
      [object setProperty:xmlDocument forKey:kGDataXMLDocumentPropertyKey];
#endif

#if GDATA_LOG_PERFORMANCE
      Microseconds(&msecs2);
      UInt64 msStart = (UInt64)msecs1.lo + (((UInt64)msecs1.hi) << 32);
      UInt64 msEnd   = (UInt64)msecs2.lo + (((UInt64)msecs2.hi) << 32);
      NSLog(@"allocation of %@ took %qu microseconds", 
            objectClass, msEnd - msStart);
#endif
      
    } else {
#if DEBUG
      NSString *invalidXML = [[[NSString alloc] initWithData:data
                                                    encoding:NSUTF8StringEncoding] autorelease];
      NSLog(@"GDataServiceBase fetching: %@\n invalidXML received: %@",[fetcher request], invalidXML);
#endif
    }
  }

  // if we created the object (or we got empty data back, as from a GData
  // delete resource request) then we succeeded  
  if (object != nil || dataLength == 0) {
    
    // if the user is fetching a feed and the ticket specifies that "next" links
    // should be followed, then do that now
    if ([ticket shouldFollowNextLinks] 
        && [object isKindOfClass:[GDataFeedBase class]]) {
      
      GDataFeedBase *latestFeed = (GDataFeedBase *)object;
      
      // append the latest feed
      [ticket accumulateFeed:latestFeed];
      
      NSURL *nextURL = [[latestFeed nextLink] URL];
      if (nextURL) {
        
        BOOL isFetchingNextFeed = [self fetchNextFeedWithURL:nextURL
                                                    delegate:delegate
                                         didFinishedSelector:finishedSelector 
                                             didFailSelector:failedSelector
                                                      ticket:ticket];
        
        // skip calling the callbacks since the ticket is still in progress
        if (isFetchingNextFeed) {
          
          return;
          
        } else {
          // the fetch didn't start; fall through to the callback for the
          // feed accumulated so far
        }
      } 
      
      // no more "next" links are present, so we don't need to accumulate more
      // entries
      GDataFeedBase *accumulatedFeed = [ticket accumulatedFeed];
      if (accumulatedFeed) {
        
        // remove the misleading "next" link from the accumulated feed
        GDataLink *accumulatedFeedNextLink = [accumulatedFeed nextLink];
        if (accumulatedFeedNextLink) {
          [accumulatedFeed removeLink:accumulatedFeedNextLink];
        }
        
        // return the completed feed as the object that was fetched
        object = accumulatedFeed;
      }
    }
    
    if (finishedSelector) {
      [delegate performSelector:finishedSelector
                     withObject:ticket
                     withObject:object];
    }
    [ticket setFetchedObject:object];
    
  } else {
    if (error == nil) {
      error = [NSError errorWithDomain:kGDataServiceErrorDomain
                                  code:kGDataCouldNotConstructObjectError
                              userInfo:nil]; 
    }
    if (failedSelector) {
      [delegate performSelector:failedSelector
                     withObject:ticket
                     withObject:error];
    }
    [ticket setFetchError:error];
  }  
  
  [fetcher setProperties:nil];

  [ticket setHasCalledCallback:YES];
  [ticket setCurrentFetcher:nil];
}

- (void)objectFetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(int)status data:(NSData *)data {

#ifdef DEBUG
  NSString *dataString = [[[NSString alloc] initWithData:data
                                            encoding:NSUTF8StringEncoding] autorelease];
  if (dataString) {
   NSLog(@"serviceBase:%@ objectFetcher:%@ failedWithStatus:%d data:%@",
         self, fetcher, status, dataString);
  }
#endif

  id delegate = [fetcher propertyForKey:kFetcherDelegateKey];

  GDataServiceTicketBase *ticket = [fetcher propertyForKey:kFetcherTicketKey];

  NSString *failedSelectorStr = [fetcher propertyForKey:kFetcherFailedSelectorKey];
  SEL failedSelector = failedSelectorStr ? NSSelectorFromString(failedSelectorStr) : nil;

  // determine the type of server response, since we will need to know if it
  // is structured XML
  NSDictionary *responseHeaders = [fetcher responseHeaders];
  NSString *contentType = [responseHeaders objectForKey:@"Content-Type"];

  NSDictionary *userInfo = [self userInfoForErrorResponseData:data
                                                  contentType:contentType];

  NSError *error = [NSError errorWithDomain:kGDataServiceErrorDomain
                                       code:status
                                   userInfo:userInfo];
  if (failedSelector) {
    [delegate performSelector:failedSelector
                   withObject:ticket
                   withObject:error];
  }

  [fetcher setProperties:nil];

  [ticket setFetchError:error];
  [ticket setHasCalledCallback:YES];
  [ticket setCurrentFetcher:nil];
}

- (void)objectFetcher:(GDataHTTPFetcher *)fetcher failedWithNetworkError:(NSError *)error {
  
  id delegate = [fetcher propertyForKey:kFetcherDelegateKey];

  GDataServiceTicketBase *ticket = [fetcher propertyForKey:kFetcherTicketKey];

  NSString *failedSelectorStr = [fetcher propertyForKey:kFetcherFailedSelectorKey];
  SEL failedSelector = failedSelectorStr ? NSSelectorFromString(failedSelectorStr) : nil;

  if (failedSelector) {
      
    [delegate performSelector:failedSelector
                   withObject:ticket
                   withObject:error]; 
  }
  
  [fetcher setProperties:nil];

  [ticket setFetchError:error];
  [ticket setHasCalledCallback:YES];
  [ticket setCurrentFetcher:nil];
}

// create an error userInfo dictionary containing a useful reason string and,
// for structured XML errors, a server error group object
- (NSDictionary *)userInfoForErrorResponseData:(NSData *)data
                                   contentType:(NSString *)contentType {

  // NSError's default localizedReason value looks like
  //   "(com.google.GDataServiceDomain error -4.)"
  //
  // The NSError domain and numeric code aren't the ones we care about
  // so much as the error present in the server response data, so
  // we'll try to store a more useful reason in the userInfo dictionary

  NSString *reasonStr = nil;
  NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];

  if ([data length] > 0) {

    // check if the response is a structured XML error string, according to the
    // response content-type header; if so, convert the XML to a
    // GDataServerErrorGroup
    if ([[contentType lowercaseString] hasPrefix:kXMLErrorContentType]) {

      GDataServerErrorGroup *errorGroup
        = [[[GDataServerErrorGroup alloc] initWithData:data] autorelease];

      if (errorGroup != nil) {

        // store the server group in the userInfo for the error
        [userInfo setObject:errorGroup forKey:kGDataStructuredErrorsKey];

        reasonStr = [[errorGroup mainError] summary];
      }
    }

    if ([userInfo count] == 0) {

      // no structured XML error was available; deal with a plaintext server
      // error response
      reasonStr = [[[NSString alloc] initWithData:data
                                         encoding:NSUTF8StringEncoding] autorelease];
    }
  }

  if (reasonStr != nil) {
    // we always store an error in the userInfo key "error"
    [userInfo setObject:reasonStr forKey:kGDataServerErrorStringKey];

    // store a user-readable "reason" to show up when an error is logged,
    // in parentheses like NSError does it
    NSString *parenthesized = [NSString stringWithFormat:@"(%@)", reasonStr];
    [userInfo setObject:parenthesized forKey:NSLocalizedFailureReasonErrorKey];
  }

  return userInfo;
}

// The object fetcher may call into this retry method; this one invokes the
// selector provided by the user.
- (BOOL)objectFetcher:(GDataHTTPFetcher *)fetcher willRetry:(BOOL)willRetry forError:(NSError *)error {
  
  id delegate = [fetcher propertyForKey:kFetcherDelegateKey];
  GDataServiceTicketBase *ticket = [fetcher propertyForKey:kFetcherTicketKey];
  
  SEL retrySelector = [ticket retrySelector];
  if (retrySelector) {
    
    willRetry = [self invokeRetrySelector:retrySelector
                                 delegate:delegate
                                   ticket:ticket
                                willRetry:willRetry
                                    error:error];
  }  
  return willRetry;
}

- (BOOL)invokeRetrySelector:(SEL)retrySelector
                   delegate:(id)delegate
                     ticket:(GDataServiceTicketBase *)ticket
                  willRetry:(BOOL)willRetry
                      error:(NSError *)error {
  
  if ([delegate respondsToSelector:retrySelector]) {
  
    // Unlike the retry selector invocation in GDataHTTPFetcher, this invocation
    // passes the ticket rather than the fetcher as argument 2
    NSMethodSignature *signature = [delegate methodSignatureForSelector:retrySelector];
    NSInvocation *retryInvocation = [NSInvocation invocationWithMethodSignature:signature];
    [retryInvocation setSelector:retrySelector];
    [retryInvocation setTarget:delegate];
    [retryInvocation setArgument:&ticket atIndex:2]; // ticket passed
    [retryInvocation setArgument:&willRetry atIndex:3];
    [retryInvocation setArgument:&error atIndex:4];
    [retryInvocation invoke];
    
    [retryInvocation getReturnValue:&willRetry];
  }
  return willRetry;  
}

- (void)addAuthenticationToFetcher:(GDataHTTPFetcher *)fetcher {
  NSString *username = [self username];
  NSString *password = [self password];
  
  if ([username length] && [password length]) {
    // We're avoiding +[NSURCredential credentialWithUser:password:persistence:]
    // because it fails to autorelease itself on OS X 10.4 .. 10.5.x
    // rdar://5596278 
    
    NSURLCredential *cred;
    cred = [[[NSURLCredential alloc] initWithUser:username
                                         password:password
                                      persistence:NSURLCredentialPersistenceForSession] autorelease];
    [fetcher setCredential:cred];
  }
}

// when a ticket is set to follow "next" links for feeds, this routine
// initiates the fetch for each additional feed
- (BOOL)fetchNextFeedWithURL:(NSURL *)nextFeedURL 
                    delegate:(id)delegate
         didFinishedSelector:(SEL)finishedSelector
             didFailSelector:(SEL)failedSelector
                      ticket:(GDataServiceTicketBase *)ticket {
  
  // sanity check the number of pages fetched already
  NSUInteger followedCounter = [ticket nextLinksFollowedCounter];

  if (followedCounter > kMaxNumberOfNextLinksFollowed) {

    // the client should be querying with a higher max results per page
    // to avoid this
    GDATA_DEBUG_ASSERT(0, @"Following next links retrieves too many pages (URL %@)",
              nextFeedURL);
    return NO;
  }
  [ticket setNextLinksFollowedCounter:(1 + followedCounter)];

  // by definition, feed requests are GETs, so objectToPost: and httpMethod:
  // should be nil
  GDataServiceTicketBase *startedTicket;
  startedTicket = [self fetchObjectWithURL:nextFeedURL
                               objectClass:[[ticket accumulatedFeed] class]
                              objectToPost:nil
                                      ETag:nil
                                httpMethod:nil
                                  delegate:delegate
                         didFinishSelector:finishedSelector
                           didFailSelector:failedSelector
                      retryInvocationValue:nil
                                    ticket:ticket];
  
  // in the bizarre case that the fetch didn't begin, startedTicket will be
  // nil.  So long as the started ticket is the same as the ticket we're
  // continuing, then we're happy.
  return (ticket == startedTicket);
}
  

- (BOOL)waitForTicket:(GDataServiceTicketBase *)ticket
              timeout:(NSTimeInterval)timeoutInSeconds
        fetchedObject:(GDataObject **)outObjectOrNil 
                error:(NSError **)outErrorOrNil {
  
  NSDate* giveUpDate = [NSDate dateWithTimeIntervalSinceNow:timeoutInSeconds];
  
  // loop until the fetch completes with an object or an error,
  // or until the timeout has expired
  while (![ticket hasCalledCallback]
         && [giveUpDate timeIntervalSinceNow] > 0) {
    
    // run the current run loop 1/1000 of a second to give the networking
    // code a chance to work
    NSDate *stopDate = [NSDate dateWithTimeIntervalSinceNow:0.001];
    [[NSRunLoop currentRunLoop] runUntilDate:stopDate]; 
  }
  
  GDataObject *fetchedObject = [ticket fetchedObject];
  
  if (outObjectOrNil) *outObjectOrNil = fetchedObject;
  if (outErrorOrNil)  *outErrorOrNil = [ticket fetchError];
  
  return (fetchedObject != nil);
}

#pragma mark -

// These external entry points all call into fetchObjectWithURL: defined above 

- (GDataServiceTicketBase *)fetchFeedWithURL:(NSURL *)feedURL
                                   feedClass:(Class)feedClass
                                    delegate:(id)delegate
                           didFinishSelector:(SEL)finishedSelector
                             didFailSelector:(SEL)failedSelector {
  
  return [self fetchObjectWithURL:feedURL
                      objectClass:feedClass
                     objectToPost:nil
                             ETag:nil
                       httpMethod:nil
                         delegate:delegate
                didFinishSelector:finishedSelector
                  didFailSelector:failedSelector
             retryInvocationValue:nil
                           ticket:nil];
}  

- (GDataServiceTicketBase *)fetchEntryWithURL:(NSURL *)entryURL
                                   entryClass:(Class)entryClass
                                     delegate:(id)delegate
                            didFinishSelector:(SEL)finishedSelector
                              didFailSelector:(SEL)failedSelector {
  
  return [self fetchObjectWithURL:entryURL
                      objectClass:entryClass
                     objectToPost:nil
                             ETag:nil
                       httpMethod:nil
                         delegate:delegate
                didFinishSelector:finishedSelector
                  didFailSelector:failedSelector
             retryInvocationValue:nil
                           ticket:nil];
}  

- (GDataServiceTicketBase *)fetchEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                            forFeedURL:(NSURL *)feedURL
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector {
  
  return [self fetchObjectWithURL:feedURL
                      objectClass:[entryToInsert class]
                     objectToPost:entryToInsert
                             ETag:nil
                       httpMethod:nil
                         delegate:delegate
                didFinishSelector:finishedSelector
                  didFailSelector:failedSelector
             retryInvocationValue:nil
                           ticket:nil];
}

- (GDataServiceTicketBase *)fetchEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                          forEntryURL:(NSURL *)entryURL
                                             delegate:(id)delegate
                                    didFinishSelector:(SEL)finishedSelector
                                      didFailSelector:(SEL)failedSelector {

  // Entries should be updated only if they contain copies of any unparsed XML
  // (unknown children and attributes.)
  //
  // To update an entry that ignores unparsed XML, first fetch a complete copy
  // with fetchEntryWithURL: (or a service-specific entry fetch method) using
  // the URL from the entry's selfLink.
  //
  // See setShouldServiceFeedsIgnoreUnknowns in GDataServiceBase.h for more
  // information.

  GDATA_ASSERT(![entryToUpdate shouldIgnoreUnknowns],
               @"unsafe update of %@", [entryToUpdate class]);

  return [self fetchObjectWithURL:entryURL
                      objectClass:[entryToUpdate class]
                     objectToPost:entryToUpdate
                             ETag:[entryToUpdate ETag]
                       httpMethod:@"PUT"
                         delegate:delegate
                didFinishSelector:finishedSelector
                  didFailSelector:failedSelector
             retryInvocationValue:nil
                           ticket:nil];
}

- (GDataServiceTicketBase *)deleteEntry:(GDataEntryBase *)entryToDelete
                               delegate:(id)delegate
                      didFinishSelector:(SEL)finishedSelector
                        didFailSelector:(SEL)failedSelector {
  
  NSString *etag = [entryToDelete ETag];
  NSURL *editURL = [[entryToDelete editLink] URL];
  
  GDATA_ASSERT(editURL != nil, @"deleting uneditable entry: %@", entryToDelete);
  
  return [self deleteResourceURL:editURL
                            ETag:etag
                        delegate:delegate
               didFinishSelector:finishedSelector
                 didFailSelector:failedSelector];
}

- (GDataServiceTicketBase *)deleteResourceURL:(NSURL *)resourceEditURL
                                     delegate:(id)delegate
                            didFinishSelector:(SEL)finishedSelector
                              didFailSelector:(SEL)failedSelector {
  // This routine is deprecated for services that have been updated to support
  // ETags
  //
  // pass through with a nil ETag

  GDATA_ASSERT(resourceEditURL != nil, @"deleting unspecified resource");

  return [self deleteResourceURL:resourceEditURL
                            ETag:nil
                        delegate:self
               didFinishSelector:finishedSelector
                 didFailSelector:failedSelector];
}

- (GDataServiceTicketBase *)deleteResourceURL:(NSURL *)resourceEditURL
                                         ETag:(NSString *)etag
                                     delegate:(id)delegate
                            didFinishSelector:(SEL)finishedSelector
                              didFailSelector:(SEL)failedSelector {
  
  GDATA_ASSERT(resourceEditURL != nil, @"deleting unspecified resource");
  
  return [self fetchObjectWithURL:resourceEditURL
                      objectClass:nil
                     objectToPost:nil
                             ETag:etag
                       httpMethod:@"DELETE"
                         delegate:delegate
                didFinishSelector:finishedSelector
                  didFailSelector:failedSelector
             retryInvocationValue:nil
                           ticket:nil];
}

- (GDataServiceTicketBase *)fetchQuery:(GDataQuery *)query
                             feedClass:(Class)feedClass
                              delegate:(id)delegate
                     didFinishSelector:(SEL)finishedSelector
                       didFailSelector:(SEL)failedSelector {
  
  return [self fetchFeedWithURL:[query URL]
                      feedClass:feedClass
                       delegate:delegate
              didFinishSelector:finishedSelector
                didFailSelector:failedSelector];
}

- (GDataServiceTicketBase *)fetchFeedWithBatchFeed:(GDataFeedBase *)batchFeed
                                        forFeedURL:(NSURL *)feedURL
                                          delegate:(id)delegate
                                 didFinishSelector:(SEL)finishedSelector
                                   didFailSelector:(SEL)failedSelector {

  // add batch namespace, if needed
  if ([[batchFeed namespaces] objectForKey:kGDataNamespaceBatchPrefix] == nil) {
    
    [batchFeed addNamespaces:[GDataEntryBase batchNamespaces]];
  }
  
  return [self fetchObjectWithURL:feedURL
                      objectClass:[batchFeed class]
                     objectToPost:batchFeed
                             ETag:nil
                       httpMethod:nil
                         delegate:delegate
                didFinishSelector:finishedSelector
                  didFailSelector:failedSelector
             retryInvocationValue:nil
                           ticket:nil];
}

#pragma mark -

// Subclasses typically implement defaultServiceVersion to specify the expected
// version of the feed, but clients may also explicitly set the version
// if they are using an instance of the base class directly.
+ (NSString *)defaultServiceVersion {
  return nil;
}

- (NSString *)serviceVersion {
  if (serviceVersion_ != nil) {
    return serviceVersion_;
  }

  NSString *str = [[self class] defaultServiceVersion];
  return str;
}

- (void)setServiceVersion:(NSString *)str {
  [serviceVersion_ autorelease];
  serviceVersion_ = [str copy];
}

- (NSString *)userAgent {
  return userAgent_; 
}

- (void)setUserAgent:(NSString *)userAgent {
  [userAgent_ release];
  userAgent_ = [userAgent copy];
}

- (NSArray *)runLoopModes {
  return runLoopModes_;
}

- (void)setRunLoopModes:(NSArray *)modes {
  [runLoopModes_ autorelease]; 
  runLoopModes_ = [modes retain];
}

// save the username and password, converting the password to non-plaintext
- (void)setUserCredentialsWithUsername:(NSString *)username
                              password:(NSString *)password {
  if (username && ![username_ isEqual:username]) {
    
    // username changed; discard history so we're not caching for the wrong
    // user
    [fetchHistory_ removeAllObjects];
  }
  
  [username_ release];
  username_ = [username copy];
  
  [password_ release];
  
  if (password) {
    password_ = [[NSMutableData alloc] initWithBytes:[password UTF8String]
                                              length:strlen([password UTF8String])];
    XorPlainMutableData(password_);
  } else {
    password_ = nil;
  }
}

- (NSString *)username {
  return username_; 
}

// return the password as plaintext
- (NSString *)password {
  if (password_) {
    XorPlainMutableData(password_);
    NSString *result = [[[NSString alloc] initWithData:password_
                                              encoding:NSUTF8StringEncoding] autorelease];
    XorPlainMutableData(password_);
    return result;
  }
  return nil;
}

// Turn on data caching to receive a copy of previously-retrieved objects.
// Otherwise, fetches may return status 304 (No Change) rather than actual data
- (void)setShouldCacheDatedData:(BOOL)flag {
  shouldCacheDatedData_ = flag;
  
  if (!flag) {
    [fetchHistory_ removeObjectForKey:kGDataHTTPFetcherHistoryDatedDataKey]; 
  }
}

- (BOOL)shouldCacheDatedData {
  return shouldCacheDatedData_; 
}

// reset the last modified dates to avoid getting a Not Modified status
// based on prior queries
- (void)clearLastModifiedDates {
  [fetchHistory_ removeObjectForKey:kGDataHTTPFetcherHistoryLastModifiedKey];
  [fetchHistory_ removeObjectForKey:kGDataHTTPFetcherHistoryDatedDataKey]; 
}

- (BOOL)serviceShouldFollowNextLinks {
  return serviceShouldFollowNextLinks_;
}

- (void)setServiceShouldFollowNextLinks:(BOOL)flag {
  serviceShouldFollowNextLinks_ = flag; 
}


// The service userData becomes the initial value for each future ticket's
// userData.
//
// Since the network transactions may begin before the client has been 
// returned the ticket by the fetch call, it's preferable to call 
// setServiceUserData before the ticket is created rather than call the
// ticket's setUserData:.  Either way, the ticket's userData:
// method will return the value.
- (void)setServiceUserData:(id)userData {
  [serviceUserData_ autorelease];
  serviceUserData_ = [userData retain];
}

- (id)serviceUserData {
  return serviceUserData_;
}

// The service properties dictionary becomes the dictionary for each future
// ticket.

- (void)setServiceProperties:(NSDictionary *)dict {
  [serviceProperties_ autorelease];
  serviceProperties_ = [dict mutableCopy];
}

- (NSDictionary *)serviceProperties {
  // be sure the returned pointer has the life of the autorelease pool,
  // in case self is released immediately
  return [[serviceProperties_ retain] autorelease];
}

- (void)setServiceProperty:(id)obj forKey:(NSString *)key {
  
  if (obj == nil) {
    // user passed in nil, so delete the property
    [serviceProperties_ removeObjectForKey:key];
  } else {
    // be sure the property dictionary exists
    if (serviceProperties_ == nil) {
      serviceProperties_ = [[NSMutableDictionary alloc] init];
    }
    [serviceProperties_ setObject:obj forKey:key];
  }
}

- (id)servicePropertyForKey:(NSString *)key {
  id obj = [serviceProperties_ objectForKey:key];
  
  // be sure the returned pointer has the life of the autorelease pool,
  // in case self is released immediately
  return [[obj retain] autorelease];
}

- (NSDictionary *)serviceSurrogates {
  return serviceSurrogates_;
}

- (void)setServiceSurrogates:(NSDictionary *)dict {
  [serviceSurrogates_ autorelease]; 
  serviceSurrogates_ = [dict retain];
}

- (BOOL)shouldServiceFeedsIgnoreUnknowns {
  return shouldServiceFeedsIgnoreUnknowns_;
}

- (void)setShouldServiceFeedsIgnoreUnknowns:(BOOL)flag {
  shouldServiceFeedsIgnoreUnknowns_ = flag;
}

- (SEL)serviceUploadProgressSelector {
  return serviceUploadProgressSelector_;
}

- (void)setServiceUploadProgressSelector:(SEL)progressSelector {
  serviceUploadProgressSelector_ = progressSelector; 
}

// retrying; see comments on retry support at the top of GDataHTTPFetcher
- (BOOL)isServiceRetryEnabled {
  return isServiceRetryEnabled_;
}

- (void)setIsServiceRetryEnabled:(BOOL)flag {
  isServiceRetryEnabled_ = flag; 
}

- (SEL)serviceRetrySelector {
  return serviceRetrySEL_; 
}

- (void)setServiceRetrySelector:(SEL)theSel {
  serviceRetrySEL_ = theSel;
}

- (NSTimeInterval)serviceMaxRetryInterval {
  return serviceMaxRetryInterval_;  
}

- (void)setServiceMaxRetryInterval:(NSTimeInterval)secs {
  serviceMaxRetryInterval_ = secs; 
}

#pragma mark -

// we want to percent-escape some of the characters that are otherwise
// considered legal in URLs when we pass them as parameters
//
// Unlike [GDataQuery stringByURLEncodingStringParameter] this does not
// replace spaces with + characters
//
// Reference: http://www.ietf.org/rfc/rfc3986.txt

- (NSString *)stringByURLEncoding:(NSString *)param {
  
  NSString *resultStr = param;
  
  CFStringRef originalString = (CFStringRef) param;
  CFStringRef leaveUnescaped = NULL;
  CFStringRef forceEscaped = CFSTR("!*'();:@&=+$,/?%#[]");
  
  CFStringRef escapedStr;
  escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                       originalString,
                                                       leaveUnescaped, 
                                                       forceEscaped,
                                                       kCFStringEncodingUTF8);
  
  if (escapedStr) {
    resultStr = [NSString stringWithString:(NSString *)escapedStr];
    CFRelease(escapedStr);
  }
  return resultStr;
}

// return a generic name and version for the current application; this avoids
// anonymous server transactions.  Applications should call setUserAgent
// to avoid the need for this method to be used.
- (NSString *)defaultApplicationIdentifier {

  // if there's a bundle ID, use that; otherwise, use the process name

  // if this code is compiled directly into an app or plug-in, we want
  // that app or plug-in's bundle; if it was loaded as part of the
  // GData framework, we'll settle for the main bundle's ID
  NSBundle *owningBundle = [NSBundle bundleForClass:[self class]];
  if (owningBundle == nil
      || [[owningBundle bundleIdentifier] isEqual:@"com.google.GDataFramework"]) {

    owningBundle = [NSBundle mainBundle];
  }

  NSString *identifier;

  NSString *bundleID = [owningBundle bundleIdentifier];
  if ([bundleID length] > 0) {
    identifier = bundleID;
  } else {
    identifier = [[NSProcessInfo processInfo] processName];
  }

  // if there's a version number, append that
  NSString *version = [owningBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

  if (version != nil) {
    identifier = [identifier stringByAppendingFormat:@"-%@", version];
  }

  // clean up whitespace and special characters
  NSString *result = [GDataUtilities userAgentStringForString:identifier];
  return result;
}
@end

@implementation GDataServiceTicketBase

+ (id)ticketForService:(GDataServiceBase *)service {
  return [[[self alloc] initWithService:service] autorelease];  
}

- (id)initWithService:(GDataServiceBase *)service {
  self = [super init];
  if (self) {
    service_ = [service retain];
    
    [self setUserData:[service serviceUserData]];
    [self setProperties:[service serviceProperties]];
    [self setSurrogates:[service serviceSurrogates]];
    [self setUploadProgressSelector:[service serviceUploadProgressSelector]];  
    [self setIsRetryEnabled:[service isServiceRetryEnabled]];
    [self setRetrySelector:[service serviceRetrySelector]];
    [self setMaxRetryInterval:[service serviceMaxRetryInterval]];   
    [self setShouldFollowNextLinks:[service serviceShouldFollowNextLinks]];
  }
  return self;
}

- (void)dealloc {
  [service_ release];
  
  [userData_ release];
  [ticketProperties_ release];
  [surrogates_ release];
  
  [currentFetcher_ release];
  [objectFetcher_ release];
  
  [postedObject_ release];
  [fetchedObject_ release];
  [accumulatedFeed_ release];
  [fetchError_ release];  
  
  [super dealloc];
}

- (NSString *)description {
  NSString *template = @"%@ 0x%lX: {service:%@ currentFetcher:%@ userData:%@}";
  return [NSString stringWithFormat:template,
    [self class], self, service_, currentFetcher_, userData_];
}

- (void)cancelTicket {
  [objectFetcher_ stopFetching];
  [objectFetcher_ setProperties:nil];
  
  [self setObjectFetcher:nil];
  [self setCurrentFetcher:nil];
  [self setUserData:nil];
  [self setProperties:nil];
  
  [service_ autorelease];
  service_ = nil;
}

- (GDataServiceBase *)service {
  return service_; 
}

- (id)userData {
  return [[userData_ retain] autorelease]; 
}

- (void)setUserData:(id)obj {
  [userData_ autorelease];
  userData_ = [obj retain];
}

- (void)setProperties:(NSDictionary *)dict {
  [ticketProperties_ autorelease];
  ticketProperties_ = [dict mutableCopy];
}

- (NSDictionary *)properties {
  // be sure the returned pointer has the life of the autorelease pool,
  // in case self is released immediately
  return [[ticketProperties_ retain] autorelease];
}

- (void)setProperty:(id)obj forKey:(NSString *)key {
  
  if (obj == nil) {
    // user passed in nil, so delete the property
    [ticketProperties_ removeObjectForKey:key];
  } else {
    // be sure the property dictionary exists
    if (ticketProperties_ == nil) {
      ticketProperties_ = [[NSMutableDictionary alloc] init];
    }
    [ticketProperties_ setObject:obj forKey:key];
  }
}

- (id)propertyForKey:(NSString *)key {
  id obj = [ticketProperties_ objectForKey:key];
  
  // be sure the returned pointer has the life of the autorelease pool,
  // in case self is released immediately
  return [[obj retain] autorelease];
}

- (NSDictionary *)surrogates {
  return surrogates_;
}

- (void)setSurrogates:(NSDictionary *)dict {
  [surrogates_ autorelease]; 
  surrogates_ = [dict retain];
}

- (SEL)uploadProgressSelector {
  return uploadProgressSelector_;
}

- (void)setUploadProgressSelector:(SEL)progressSelector {
  uploadProgressSelector_ = progressSelector; 
}

- (BOOL)shouldFollowNextLinks {
  return shouldFollowNextLinks_;  
}

- (void)setShouldFollowNextLinks:(BOOL)flag {
  shouldFollowNextLinks_ = flag;
}

- (BOOL)isRetryEnabled {
  return isRetryEnabled_;  
}

- (void)setIsRetryEnabled:(BOOL)flag {
  isRetryEnabled_ = flag; 
}; 

- (SEL)retrySelector {
  return retrySEL_; 
}

- (void)setRetrySelector:(SEL)theSelector {
  retrySEL_ = theSelector;  
}

- (NSTimeInterval)maxRetryInterval {
  return maxRetryInterval_;  
}

- (void)setMaxRetryInterval:(NSTimeInterval)secs {
  maxRetryInterval_ = secs; 
}

- (GDataHTTPFetcher *)currentFetcher {
  return [[currentFetcher_ retain] autorelease]; 
}

- (void)setCurrentFetcher:(GDataHTTPFetcher *)fetcher {
  [currentFetcher_ autorelease];
  currentFetcher_ = [fetcher retain];
}

- (GDataHTTPFetcher *)objectFetcher {
  return [[objectFetcher_ retain] autorelease]; 
}

- (void)setObjectFetcher:(GDataHTTPFetcher *)fetcher {
  [objectFetcher_ autorelease];
  objectFetcher_ = [fetcher retain];
}

- (NSInteger)statusCode {
  return [objectFetcher_ statusCode];  
}

- (void)setHasCalledCallback:(BOOL)flag {
  hasCalledCallback_ = flag; 
}

- (BOOL)hasCalledCallback {
  return hasCalledCallback_;  
}

- (void)setPostedObject:(GDataObject *)obj {
  [postedObject_ autorelease];
  postedObject_ = [obj retain];
}

- (GDataObject *)postedObject {
  return postedObject_;
}

- (void)setFetchedObject:(GDataObject *)obj {
  [fetchedObject_ autorelease];
  fetchedObject_ = [obj retain];
}

- (GDataObject *)fetchedObject {
  return fetchedObject_;
}

- (void)setFetchError:(NSError *)error {
  [fetchError_ autorelease];
  fetchError_ = [error retain];
}

- (NSError *)fetchError {
  return fetchError_; 
}

- (void)setAccumulatedFeed:(GDataFeedBase *)feed {
  [accumulatedFeed_ autorelease];
  accumulatedFeed_ = [feed retain];
}

// accumulateFeed is used by the service to append an incomplete feed
// to the ticket when shouldFollowNextLinks is enabled
- (GDataFeedBase *)accumulatedFeed {
  return accumulatedFeed_;
}

- (void)accumulateFeed:(GDataFeedBase *)newFeed {
  
  GDataFeedBase *accumulatedFeed = [self accumulatedFeed];
  if (accumulatedFeed == nil) {
    
    // the new feed becomes the accumulated feed
    [self setAccumulatedFeed:newFeed];
    
  } else {
    
    // A feed's addEntry: routine requires that a new entry's parent
    // not be set to some other feed.  Calling addEntryWithEntry: would make
    // a new, parentless copy of the entry for us, but that would be a needless
    // copy. Instead, we'll explicitly clear the entry's parent and call
    // addEntry:.
    
    NSArray *newEntries = [newFeed entries];
    GDataEntryBase *entry;
    
    GDATA_FOREACH(entry, newEntries) {
      [entry setParent:nil];
      [accumulatedFeed addEntry:entry];
    }
  }
}

- (void)setNextLinksFollowedCounter:(NSUInteger)val {
  nextLinksFollowedCounter_ = val;
}

- (NSUInteger)nextLinksFollowedCounter {
  return nextLinksFollowedCounter_;
}

@end

