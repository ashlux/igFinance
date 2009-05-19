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
//  GDataEntrySpreadsheet.m
//

#define GDATASPREADSHEET_DEFINE_GLOBALS 1

#import "GDataEntrySpreadsheet.h"

// extensions



@implementation GDataEntrySpreadsheet

+ (NSDictionary *)spreadsheetNamespaces {
  NSMutableDictionary *namespaces = [NSMutableDictionary dictionaryWithDictionary:
    [GDataEntryBase baseGDataNamespaces]];

  [namespaces setObject:kGDataNamespaceGSpread 
                 forKey:kGDataNamespaceGSpreadPrefix]; // "gs"
  
  [namespaces setObject:kGDataNamespaceGSpreadCustom 
                 forKey:kGDataNamespaceGSpreadCustomPrefix]; // "gsx"

  return namespaces;
}

+ (GDataEntrySpreadsheet *)spreadsheetEntry {
  GDataEntrySpreadsheet *entry = [[[GDataEntrySpreadsheet alloc] init] autorelease];

  [entry setNamespaces:[GDataEntrySpreadsheet spreadsheetNamespaces]];
  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  // spreadsheet categories do not use the standard Kind scheme
  // (kGDataCategoryScheme) so cannot be init'd by GDataEntryBase
  return nil;
}

+ (void)load {
  // spreadsheet categories do not use the standard Kind scheme
  // (kGDataCategoryScheme) so cannot be registered with +registerEntryClass
  [GDataEntryBase registerEntryClass:[self class]
               forCategoryWithScheme:nil
                                term:kGDataCategorySpreadsheet];
}

- (id)init {
  self = [super init];
  if (self) {
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategorySchemeSpreadsheet
                                                   term:kGDataCategorySpreadsheet]];
  }
  return self;
}

#pragma mark -

- (GDataLink *)spreadsheetLink {
  return [self alternateLink]; 
}

- (GDataLink *)worksheetsLink {
  GDATA_DEBUG_ASSERT_MAX_SERVICE_V1();

  return [self linkWithRelAttributeValue:kGDataLinkWorksheetsFeed];
}

- (NSURL *)worksheetsFeedURL {

  // the worksheets feed URL is the URI in the entry's content element
  GDataEntryContent *content = [self content];

  if ([[content type] hasPrefix:@"application/atom+xml"]) {
    return [content sourceURL];
  }

  // prior to V2 feeds, the URL is in a link
  return [[self linkWithRelAttributeValue:kGDataLinkWorksheetsFeed] URL];
}

+ (NSString *)defaultServiceVersion {
  return kGDataSpreadsheetDefaultServiceVersion;
}
@end
