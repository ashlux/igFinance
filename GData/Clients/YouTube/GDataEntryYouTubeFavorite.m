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
//  GDataEntryYouTubeFavorite.m
//

#import "GDataEntryYouTubeFavorite.h"
#import "GDataEntryYouTubeVideo.h"

@implementation GDataEntryYouTubeFavorite

+ (GDataEntryYouTubeFavorite *)favoriteEntry {

  GDataEntryYouTubeFavorite *entry = [[[self alloc] init] autorelease];

  [entry setNamespaces:[GDataEntryYouTubeVideo youTubeNamespaces]];

  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryYouTubeFavorite;
}

+ (void)load {
  [self registerEntryClass];
}

@end
