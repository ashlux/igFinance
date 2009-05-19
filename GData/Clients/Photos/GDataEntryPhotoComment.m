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
//  GDataEntryPhotoComment.m
//

#import "GDataEntryPhotoComment.h"
#import "GDataPhotoElements.h"

// extensions

@implementation GDataEntryPhotoComment

+ (GDataEntryPhotoComment *)commentEntryWithString:(NSString *)commentStr {
  
  GDataEntryPhotoComment *entry = [[[GDataEntryPhotoComment alloc] init] autorelease];

  [entry setNamespaces:[GDataEntryPhotoComment photoNamespaces]];
  
  [entry setContent:[GDataEntryContent contentWithString:commentStr]];
  
  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryPhotosComment;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  // common photo extensions
  Class entryClass = [self class];
  
  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataPhotoAlbumID class],
   [GDataPhotoPhotoID class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self albumID] withName:@"albumID"];
  [self addToArray:items objectDescriptionIfNonNil:[self photoID] withName:@"photoID"];
  
  return items;
}
#endif

#pragma mark -

- (NSString *)albumID {
  GDataPhotoAlbumID *obj = [self objectForExtensionClass:[GDataPhotoAlbumID class]];
  return [obj stringValue];
}

- (void)setAlbumID:(NSString *)str {
  GDataObject *obj = [GDataPhotoAlbumID valueWithString:str];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSString *)photoID {
  GDataPhotoPhotoID *obj = [self objectForExtensionClass:[GDataPhotoPhotoID class]];
  return [obj stringValue];
}

- (void)setPhotoID:(NSString *)str {
  GDataObject *obj = [GDataPhotoPhotoID valueWithString:str];
  [self setObject:obj forExtensionClass:[obj class]];  
}


@end
