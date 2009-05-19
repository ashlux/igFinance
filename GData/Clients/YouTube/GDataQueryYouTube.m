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
//  GDataQueryYouTube.m
//

#define GDATAQUERYYOUTUBE_DEFINE_GLOBALS 1
#import "GDataQueryYouTube.h"

#import "GDataServiceGoogleYouTube.h"

static NSString *const kTimeParamName = @"time";
static NSString *const kFormatParamName = @"format";
static NSString *const kSafeSearchParamName = @"safeSearch";
static NSString *const kRestrictionParamName = @"restriction";
static NSString *const kLanguageRestrictionParamName = @"lr";
static NSString *const kLocationParamName = @"location";
static NSString *const kLocationRadiusParamName = @"location-radius";
static NSString *const kRacyParamName = @"racy";
static NSString *const kUploaderParamName = @"uploader";

// Deprecated: The vq parameter has been replaced with
// "q" (kFullTextQueryStringParamName) for v2
static NSString *const kVideoQueryParamName = @"vq";

@implementation GDataQueryYouTube

+ (GDataQueryYouTube *)youTubeQueryWithFeedURL:(NSURL *)feedURL {
  return [[[self alloc] initWithFeedURL:feedURL] autorelease];   
}


- (void)setVideoQuery:(NSString *)str {
  [self addCustomParameterWithName:kVideoQueryParamName
                             value:str];
}

- (NSString *)videoQuery {
  return [self valueForParameterWithName:kVideoQueryParamName];
}

- (void)setFormat:(NSString *)str {
  [self addCustomParameterWithName:kFormatParamName
                             value:str];
}

- (NSString *)format {
  return [self valueForParameterWithName:kFormatParamName];
}

- (void)setTimePeriod:(NSString *)str {
  [self addCustomParameterWithName:kTimeParamName
                             value:str];
}

- (NSString *)timePeriod {
  return [self valueForParameterWithName:kTimeParamName];
}

- (void)setRestriction:(NSString *)str {
  [self addCustomParameterWithName:kRestrictionParamName
                             value:str];
}

- (NSString *)restriction {
  return [self valueForParameterWithName:kRestrictionParamName];
}

- (void)setLanguageRestriction:(NSString *)str {
  [self addCustomParameterWithName:kLanguageRestrictionParamName
                             value:str];
}

- (NSString *)languageRestriction {
  return [self valueForParameterWithName:kLanguageRestrictionParamName];
}

- (void)setLocation:(NSString *)str {
  [self addCustomParameterWithName:kLocationParamName
                             value:str];
}

- (NSString *)location {
  return [self valueForParameterWithName:kLocationParamName];
}

- (void)setLocationRadius:(NSString *)str {
  [self addCustomParameterWithName:kLocationRadiusParamName
                             value:str];
}

- (NSString *)locationRadius {
  return [self valueForParameterWithName:kLocationRadiusParamName];
}

- (void)setUploader:(NSString *)str {
  [self addCustomParameterWithName:kUploaderParamName
                             value:str];
}

- (NSString *)uploader {
  return [self valueForParameterWithName:kUploaderParamName];
}

- (void)setSafeSearch:(NSString *)str {
  [self addCustomParameterWithName:kSafeSearchParamName
                             value:str];
}

- (NSString *)safeSearch {
  return [self valueForParameterWithName:kSafeSearchParamName];
}

// racy is deprecated for GData v2
- (void)setAllowRacy:(BOOL)flag {
    // adding nil removes the custom parameter
  [self addCustomParameterWithName:kRacyParamName
                             value:(flag ? @"include" : nil)];
}

- (BOOL)allowRacy {
  NSString *str = [self valueForParameterWithName:kRacyParamName];
  return ([str caseInsensitiveCompare:@"include"] == NSOrderedSame);
}

@end
