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
//  GDataFeedCalendar.m
//

#import "GDataEntryCalendar.h"
#import "GDataEntryCalendarEvent.h"
#import "GDataFeedCalendar.h"
#import "GDataCategory.h"

@implementation GDataFeedCalendar

+ (GDataFeedCalendar *)calendarFeedWithXMLData:(NSData *)data {
  return [[[self alloc] initWithData:data] autorelease];
}

+ (GDataFeedCalendar *)calendarFeed {
  GDataFeedCalendar *feed = [[[self alloc] init] autorelease];
  [feed setNamespaces:[GDataEntryCalendar calendarNamespaces]];
  return feed;
}

- (id)init {
  self = [super init];
  if (self) {
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                   term:kGDataCategoryEvent]];
  }
  return self;
}

- (Class)classForEntries {
  return [GDataEntryCalendar class];
}

+ (NSString *)defaultServiceVersion {
  return kGDataCalendarDefaultServiceVersion;
}

@end
