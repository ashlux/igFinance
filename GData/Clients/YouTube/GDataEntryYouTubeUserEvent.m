/* Copyright (c) 2009 Google Inc.
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
//  GDataEntryYouTubeUserEvent.m
//

#import "GDataEntryYouTubeUserEvent.h"
#import "GDataEntryYouTubeVideo.h"
#import "GDataYouTubeElements.h"
#import "GDataRating.h"

@implementation GDataEntryYouTubeUserEvent

+ (GDataEntryYouTubeUserEvent *)userEventEntry {

  GDataEntryYouTubeUserEvent *entry = [[[self alloc] init] autorelease];

  [entry setNamespaces:[GDataEntryYouTubeVideo youTubeNamespaces]];

  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryYouTubeUserEvent;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   // YouTube element extensions
   [GDataYouTubeVideoID class],
   [GDataYouTubeUsername class],
   [GDataRating class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"eventType", @"userEventType", kGDataDescValueLabeled }, // report the category's term
    { @"videoID",   @"videoID",       kGDataDescValueLabeled },
    { @"username",  @"username",      kGDataDescValueLabeled },
    { @"rating",    @"rating",        kGDataDescValueLabeled },
    { nil, nil, 0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataYouTubeDefaultServiceVersion;
}

#pragma mark -

- (NSString *)videoID {
  GDataYouTubeVideoID *obj;

  obj = [self objectForExtensionClass:[GDataYouTubeVideoID class]];
  return [obj stringValue];
}

- (void)setVideoID:(NSString *)str {
  GDataYouTubeVideoID *obj = [GDataYouTubeVideoID valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeVideoID class]];
}

- (NSString *)username {
  GDataYouTubeUsername *obj = [self objectForExtensionClass:[GDataYouTubeUsername class]];
  return [obj stringValue];
}

- (void)setUsername:(NSString *)str {
  GDataYouTubeUsername *obj = [GDataYouTubeUsername valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeUsername class]];
}

- (GDataRating *)rating {
  return [self objectForExtensionClass:[GDataRating class]];
}

- (void)setRating:(GDataRating *)obj {
  [self setObject:obj forExtensionClass:[GDataRating class]];
}

#pragma mark -

- (NSString *)userEventType {

  NSArray *eventCats = [self categoriesWithScheme:kGDataSchemeYouTubeUserEvents];

  if ([eventCats count] > 0) {
    GDataCategory *category = [eventCats objectAtIndex:0];
    NSString *typeStr = [category term];
    return typeStr;
  }
  return nil;
}

- (void)setUserEventType:(NSString *)typeStr {

  // replace any existing event categories (though there should be only one)
  // as in the Java interfaces
  NSArray *eventCats = [self categoriesWithScheme:kGDataSchemeYouTubeUserEvents];

  GDataCategory *cat;
  GDATA_FOREACH(cat, eventCats) {
    [self removeCategory:cat];
  }

  if (typeStr != nil) {
    GDataCategory *newCat;
    newCat = [GDataCategory categoryWithScheme:kGDataSchemeYouTubeUserEvents
                                          term:typeStr];
    [self addCategory:newCat];
  }
}


#pragma mark -

- (GDataLink *)videoLink {
  return [self linkWithRelAttributeValue:kGDataLinkYouTubeVideo];
}

- (GDataLink *)commentLink {
  return [self linkWithRelAttributeValue:kGDataLinkYouTubeComments];
}

@end
