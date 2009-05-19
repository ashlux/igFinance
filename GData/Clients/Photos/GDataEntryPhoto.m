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
//  GDataEntryPhoto.m
//

#import "GDataEntryPhoto.h"
#import "GDataPhotoElements.h"

@implementation GDataEntryPhoto

+ (GDataEntryPhoto *)photoEntry {
  
  GDataEntryPhoto *entry = [[[GDataEntryPhoto alloc] init] autorelease];

  [entry setNamespaces:[GDataEntryPhoto photoNamespaces]];
  
  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryPhotosPhoto;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  // Photo extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataPhotoVersion class], [GDataPhotoPosition class],
   [GDataPhotoWidth class], [GDataPhotoHeight class],
   [GDataPhotoRotation class], [GDataPhotoSize class],
   [GDataPhotoAlbumID class], [GDataPhotoTimestamp class],
   [GDataPhotoCommentCount class], [GDataPhotoCommentingEnabled class],
   [GDataPhotoClient class], [GDataPhotoChecksum class],
   [GDataPhotoVideoStatus class], [GDataMediaGroup class],
   [GDataEXIFTags class],
   nil];
  
  [GDataGeo addGeoExtensionDeclarationsToObject:self
                                 forParentClass:entryClass];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  static struct GDataDescriptionRecord descRecs[] = {
    { @"albumID",         @"albumID",         kGDataDescValueLabeled },
    { @"checksum",        @"checksum",        kGDataDescValueLabeled },
    { @"client",          @"client",          kGDataDescValueLabeled },
    { @"commentCount",    @"commentCount",    kGDataDescValueLabeled },
    { @"commentsEnabled", @"commentsEnabled", kGDataDescValueLabeled },
    { @"height",          @"height",          kGDataDescValueLabeled },
    { @"width",           @"width",           kGDataDescValueLabeled },
    { @"videoStatus",     @"videoStatus",     kGDataDescValueLabeled },
    { @"position",        @"position",        kGDataDescValueLabeled },
    { @"rotation",        @"rotation",        kGDataDescValueLabeled },
    { @"size",            @"size",            kGDataDescValueLabeled },
    { @"timestamp",       @"timestamp",       kGDataDescValueLabeled },
    { @"version",         @"version",         kGDataDescValueLabeled },
    { @"mediaGroup",      @"mediaGroup",      kGDataDescValueLabeled },
    { @"exifTags",        @"EXIFTags",        kGDataDescValueLabeled },
    { @"geoLocation",     @"geoLocation",     kGDataDescValueLabeled },
    { nil, nil, 0 }
  };
  
  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

// binary photo uploading

- (void)setPhotoData:(NSData *)data {
  [self setUploadData:data];
}

- (NSData *)photoData {
  return [self uploadData];
}

- (void)setPhotoMIMEType:(NSString *)str {
  [self setUploadMIMEType:str];
}

- (NSString *)photoMIMEType {
  return [self uploadMIMEType];
}

#pragma mark -

- (NSString *)albumID {
  GDataPhotoAlbumID *obj = [self objectForExtensionClass:[GDataPhotoAlbumID class]];
  return [obj stringValue];
}

- (void)setAlbumID:(NSString *)str {
  GDataObject *obj = [GDataPhotoAlbumID valueWithString:str];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSString *)checksum {
  GDataPhotoChecksum *obj = [self objectForExtensionClass:[GDataPhotoChecksum class]];
  return [obj stringValue];
}

- (void)setChecksum:(NSString *)str {
  GDataObject *obj = [GDataPhotoChecksum valueWithString:str];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSString *)client {
  GDataPhotoClient *obj = [self objectForExtensionClass:[GDataPhotoClient class]];
  return [obj stringValue];
}

- (void)setClient:(NSString *)str {
  GDataObject *obj = [GDataPhotoClient valueWithString:str];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSNumber *)commentCount {
  // int
  GDataPhotoCommentCount *obj = [self objectForExtensionClass:[GDataPhotoCommentCount class]];
  return [obj intNumberValue];
}

- (void)setCommentCount:(NSNumber *)num {
  GDataObject *obj = [GDataPhotoCommentCount valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSNumber *)commentsEnabled {
  // BOOL
  GDataPhotoCommentingEnabled *obj = [self objectForExtensionClass:[GDataPhotoCommentingEnabled class]];
  return [obj boolNumberValue];
}

- (void)setCommentsEnabled:(NSNumber *)num {
  GDataObject *obj = [GDataPhotoCommentingEnabled valueWithBool:[num boolValue]];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSNumber *)height {
  // long long
  GDataPhotoHeight *obj = [self objectForExtensionClass:[GDataPhotoHeight class]];
  return [obj longLongNumberValue];
}

- (void)setHeight:(NSNumber *)num {
  GDataObject *obj = [GDataPhotoHeight valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSNumber *)position {
  // double
  GDataPhotoPosition *obj = [self objectForExtensionClass:[GDataPhotoPosition class]];
  return [obj doubleNumberValue];
}

- (void)setPosition:(NSNumber *)num {
  GDataObject *obj = [GDataPhotoPosition valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSNumber *)rotation {
  // int
  GDataPhotoRotation *obj = [self objectForExtensionClass:[GDataPhotoRotation class]];
  return [obj intNumberValue];
}

- (void)setRotation:(NSNumber *)num {
  GDataObject *obj = [GDataPhotoRotation valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSNumber *)size {
  // long long
  GDataPhotoSize *obj = [self objectForExtensionClass:[GDataPhotoSize class]];
  return [obj longLongNumberValue];
}

- (void)setSize:(NSNumber *)num {
  GDataObject *obj = [GDataPhotoSize valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (GDataPhotoTimestamp *)timestamp {
  GDataPhotoTimestamp *obj = [self objectForExtensionClass:[GDataPhotoTimestamp class]];
  return obj ;
}

- (void)setTimestamp:(GDataPhotoTimestamp *)obj {
  [self setObject:obj forExtensionClass:[GDataPhotoTimestamp class]];  
}

- (NSString *)version {
  GDataPhotoVersion *obj = [self objectForExtensionClass:[GDataPhotoVersion class]];
  return [obj stringValue];
}

- (void)setVersion:(NSString *)str {
  GDataObject *obj = [GDataPhotoVersion valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataPhotoVersion class]];  
}

- (NSNumber *)width {
  // long long
  GDataPhotoWidth *obj = [self objectForExtensionClass:[GDataPhotoWidth class]];
  return [obj longLongNumberValue];
}

- (void)setWidth:(NSNumber *)num {
  GDataObject *obj = [GDataPhotoWidth valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSString *)videoStatus {
  GDataPhotoVideoStatus *obj = [self objectForExtensionClass:[GDataPhotoVideoStatus class]];
  return [obj stringValue];
}

- (void)setVideoStatus:(NSString *)str {
  GDataPhotoVideoStatus *obj = [GDataPhotoVideoStatus valueWithString:str];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (GDataMediaGroup *)mediaGroup {
  return (GDataMediaGroup *) [self objectForExtensionClass:[GDataMediaGroup class]];
}

- (void)setMediaGroup:(GDataMediaGroup *)obj {
  [self setObject:obj forExtensionClass:[GDataMediaGroup class]];
}

#pragma mark -

- (GDataGeo *)geoLocation {
  return [GDataGeo geoLocationForObject:self];
}

- (void)setGeoLocation:(GDataGeo *)geo {
  [GDataGeo setGeoLocation:geo forObject:self];
}

// EXIF tag support
- (GDataEXIFTags *)EXIFTags {
  return (GDataEXIFTags *) [self objectForExtensionClass:[GDataEXIFTags class]];
}

- (void)setEXIFTags:(GDataEXIFTags *)tags {
  [self setObject:tags forExtensionClass:[GDataEXIFTags class]];   
}

@end
