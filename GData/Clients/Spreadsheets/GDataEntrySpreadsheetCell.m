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
//  GDataEntrySpreadsheetCell.m
//

#define GDATASPREADSHEETCELL_DEFINE_GLOBALS 1

#import "GDataEntrySpreadsheetCell.h"
#import "GDataEntrySpreadsheet.h"
#import "GDataSpreadsheetCell.h"

// extensions



@implementation GDataEntrySpreadsheetCell

+ (GDataEntrySpreadsheetCell *)spreadsheetCellEntryWithCell:(GDataSpreadsheetCell *)cell {
  
  GDataEntrySpreadsheetCell *entry = [[[GDataEntrySpreadsheetCell alloc] init] autorelease];

  [entry setNamespaces:[GDataEntrySpreadsheet spreadsheetNamespaces]];
  
  [entry setCell:cell];
  
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
                                term:kGDataCategorySpreadsheetCell];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  // SpreadsheetCell extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataSpreadsheetCell class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self cell] withName:@"cell"];
  
  return items;
}
#endif

- (id)init {
  self = [super init];
  if (self) {
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategorySchemeSpreadsheet
                                                   term:kGDataCategorySpreadsheetCell]];
  }
  return self;
}

+ (NSString *)defaultServiceVersion {
  return kGDataSpreadsheetDefaultServiceVersion;
}

#pragma mark -

- (GDataSpreadsheetCell *)cell {
  GDataSpreadsheetCell *obj = 
    (GDataSpreadsheetCell *) [self objectForExtensionClass:[GDataSpreadsheetCell class]];
  
  return obj;
}

- (void)setCell:(GDataSpreadsheetCell *)cell {
  [self setObject:cell forExtensionClass:[GDataSpreadsheetCell class]];
}

#pragma mark -

- (GDataLink *)sourceLink { // cell source
  return [self linkWithRelAttributeValue:kGDataLinkSource]; 
}

@end
