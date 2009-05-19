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
//  GDataQueryDocument.m
//

#define GDATAQUERYDOCS_DEFINE_GLOBALS 1
#import "GDataQueryDocs.h"

static NSString *const kTitleParamName = @"title";
static NSString *const kExactTitleParamName = @"title-exact";
static NSString *const kParentFolderParamName = @"folder";
static NSString *const kShowFoldersParamName = @"showfolders";
static NSString *const kOwnerParamName = @"owner";
static NSString *const kReaderParamName = @"reader";
static NSString *const kWriterParamName = @"writer";
static NSString *const kOpenedMinParamName = @"opened-min";
static NSString *const kOpenedMaxParamName = @"opened-max";


@implementation GDataQueryDocs

+ (GDataQueryDocs *)documentQueryWithFeedURL:(NSURL *)feedURL {
  return [[[self alloc] initWithFeedURL:feedURL] autorelease];   
}

- (NSString *)titleQuery {
  NSString *str = [self valueForParameterWithName:kTitleParamName];
  return str;  
}

- (void)setTitleQuery:(NSString *)str {
  [self addCustomParameterWithName:kTitleParamName value:str];
}

- (BOOL)isTitleQueryExact {
  return [self boolValueForParameterWithName:kExactTitleParamName
                                defaultValue:NO];
}

- (void)setIsTitleQueryExact:(BOOL)flag {
  [self addCustomParameterWithName:kExactTitleParamName
                         boolValue:flag
                      defaultValue:NO];
}

- (NSString *)parentFolderName {
  NSString *str = [self valueForParameterWithName:kParentFolderParamName];
  return str;
}

- (void)setParentFolderName:(NSString *)str {
  [self addCustomParameterWithName:kParentFolderParamName value:str];
}

- (BOOL)shouldShowFolders {
  return [self boolValueForParameterWithName:kShowFoldersParamName
                                defaultValue:NO];
}

- (void)setShouldShowFolders:(BOOL)flag {
  [self addCustomParameterWithName:kShowFoldersParamName
                         boolValue:flag
                      defaultValue:NO];
}

- (void)setOwner:(NSString *)str {
  [self addCustomParameterWithName:kOwnerParamName value:str];
}

- (NSString *)owner {
  NSString *str = [self valueForParameterWithName:kOwnerParamName];
  return str;
}

- (void)setReader:(NSString *)str {
  [self addCustomParameterWithName:kReaderParamName value:str];
}

- (NSString *)reader {
  NSString *str = [self valueForParameterWithName:kReaderParamName];
  return str;
}

- (void)setWriter:(NSString *)str {
  [self addCustomParameterWithName:kWriterParamName value:str];
}

- (NSString *)writer {
  NSString *str = [self valueForParameterWithName:kWriterParamName];
  return str;
}

- (void)setOpenedMinDateTime:(GDataDateTime *)dateTime {
  [self addCustomParameterWithName:kOpenedMinParamName
                          dateTime:dateTime];
}

- (GDataDateTime *)openedMinDateTime {
  return [self dateTimeForParameterWithName:kOpenedMinParamName];
}

- (void)setOpenedMaxDateTime:(GDataDateTime *)dateTime {
  [self addCustomParameterWithName:kOpenedMaxParamName
                          dateTime:dateTime];
}

- (GDataDateTime *)openedMaxDateTime {
  return [self dateTimeForParameterWithName:kOpenedMaxParamName];
}
@end
