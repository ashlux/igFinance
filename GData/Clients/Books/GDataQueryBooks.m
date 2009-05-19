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
//  GDataQueryBooks.m
//

#define GDATAQUERYBOOKS_DEFINE_GLOBALS 1
#import "GDataQueryBooks.h"

static NSString *const kMinViewabilityParamName = @"min-viewability";

@implementation GDataQueryBooks

+ (GDataQueryBooks *)booksQueryWithFeedURL:(NSURL *)feedURL {
  return [[[self alloc] initWithFeedURL:feedURL] autorelease];   
}

#pragma mark -

- (void)setMinimumViewability:(NSString *)str {
  [self addCustomParameterWithName:kMinViewabilityParamName
                             value:str];
}

- (NSString *)minimumViewability {
  NSString *str = [self valueForParameterWithName:kMinViewabilityParamName];
  return str;
}

@end
