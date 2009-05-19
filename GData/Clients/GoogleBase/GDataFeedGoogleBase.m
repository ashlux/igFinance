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
//  GDataFeedGoogleBase.m
//


#import "GDataFeedGoogleBase.h"
#import "GDataEntryGoogleBase.h"

@implementation GDataFeedGoogleBase

+ (GDataFeedGoogleBase *)googleBaseFeed {
  GDataFeedGoogleBase *feed = [[[GDataFeedGoogleBase alloc] init] autorelease];

  [feed setNamespaces:[GDataEntryGoogleBase googleBaseNamespaces]];
  return feed;
}

+ (GDataFeedGoogleBase *)googleBaseFeedWithXMLData:(NSData *)data {
  return [[[self alloc] initWithData:data] autorelease];
}

- (Class)classForEntries {
  return [GDataEntryGoogleBase class];
}

+ (NSString *)defaultServiceVersion {
  return kGDataGoogleBaseDefaultServiceVersion;
}

@end
