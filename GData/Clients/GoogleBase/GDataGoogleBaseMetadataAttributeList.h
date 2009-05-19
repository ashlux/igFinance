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
//  GDataGoogleBaseMetadataAttributeList.h
//

#import "GDataObject.h"
#import "GDataGoogleBaseMetadataAttribute.h"

// for gm:attributes, like 
// <gm:attributes>
//  <gm:attribute   ...>
// </gm:attributes>

@interface GDataGoogleBaseMetadataAttributeList : GDataObject <NSCopying, GDataExtension> {
}

+ (GDataGoogleBaseMetadataAttributeList *)metadataAttributeList;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;


- (NSArray *)metadataAttributes;
- (void)setMetadataAttributes:(NSArray *)attributes;
- (void)addMetadataAttribute:(GDataGoogleBaseMetadataAttribute *)attribute;

@end
