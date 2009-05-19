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
//  GDataGoogleBaseMetadataItemType.h
//

#import "GDataObject.h"

// for values, like <gm:item_type>fred's thing</gm:item_type>

@interface GDataGoogleBaseMetadataItemType : GDataObject <NSCopying, GDataExtension> {
  NSString *value_;
}

+ (GDataGoogleBaseMetadataItemType *)metadataItemTypeWithValue:(NSString *)value;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;

- (NSString *)value;
- (void)setValue:(NSString *)str;

@end
