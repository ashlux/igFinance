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
//  GDataFeedBase.m
//

#define GDATAFEEDBASE_DEFINE_GLOBALS 1
#import "GDataFeedBase.h"

#import "GDataBaseElements.h"

//   eventually we'll change the opensearch extensio URI, as in...
//  @implementation GDataOpenSearchTotalResults1_1 
//  + (NSString *)extensionElementURI       { return kGDataNamespaceOpenSearch1_1; }
//  @end
//
//  for now, we can rely on the openSearch: prefix string finding us any
//  OpenSearch 1.1 elements despite the different URI


@interface GDataFeedBase (PrivateMethods)
- (void)setupFromXMLElement:(NSXMLElement *)root;
@end

@implementation GDataFeedBase

+ (NSString *)standardFeedKind {

  // overridden by feed subclasses
  //
  // Feeds and entries typically have a "kind" atom:category element
  // indicating their contents; see
  //    http://code.google.com/apis/gdata/elements.html#Introduction
  //
  // Subclasses may override this method with the "term" attribute string
  // for their kind category.  This is used in the plain -init method,
  // and from +registerFeedClass
  //

  return nil;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class feedClass = [self class];
  
  [self addExtensionDeclarationForParentClass:feedClass
                                 childClasses:
   
   // GData extensions
   [GDataResourceID class],

   // Atom extensions
   [GDataAtomID class], 
   [GDataAtomTitle class], 
   [GDataAtomSubtitle class], 
   [GDataAtomRights class],
   [GDataAtomIcon class], 
   [GDataAtomLogo class], 
   [GDataLink class],
   [GDataAtomAuthor class],
   [GDataAtomContributor class],
   [GDataCategory class],
   [GDataAtomUpdatedDate class], 

   // atom publishing control support
   [GDataAtomPubControl atomPubControlClassForObject:self],
   
   // batch support
   [GDataBatchOperation class],
   nil];

  if ([self isServiceVersion1]) {
    
    // GData version 1 classes 
    [self addExtensionDeclarationForParentClass:feedClass
                                   childClasses:
     
     [GDataOpenSearchTotalResults1_0 class], 
     [GDataOpenSearchStartIndex1_0 class], 
     [GDataOpenSearchItemsPerPage1_0 class], 
     nil];
    
  } else {
    // GData version 2 classes
    [self addExtensionDeclarationForParentClass:feedClass
                                   childClasses:
     
     [GDataOpenSearchTotalResults1_1 class], 
     [GDataOpenSearchStartIndex1_1 class], 
     [GDataOpenSearchItemsPerPage1_1 class], 
     nil];
  }

  // Attributes
  [self addAttributeExtensionDeclarationForParentClass:feedClass
                                            childClass:[GDataETagAttribute class]];
}

+ (id)feedWithXMLData:(NSData *)data {
  return [[[self alloc] initWithData:data] autorelease];
}

- (id)init {
  self = [super init];
  if (self) {
    // if the subclass declares a kind, then add a category element for the
    // kind
    NSString *kind = [[self class] standardFeedKind];
    if (kind) {
      GDataCategory *category;

      category = [GDataCategory categoryWithScheme:kGDataCategoryScheme
                                              term:kind];
      [self addCategory:category];
    }
  }
  return self;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  
  // entry point for creation of feeds inside elements
  self = [super initWithXMLElement:element
                            parent:nil];
  if (self) {
    [self setupFromXMLElement:element];
  }
  return self;
}

- (id)initWithData:(NSData *)data {
  return [self initWithData:data
             serviceVersion:nil
       shouldIgnoreUnknowns:NO];
}

- (id)initWithData:(NSData *)data
    serviceVersion:(NSString *)serviceVersion
shouldIgnoreUnknowns:(BOOL)shouldIgnoreUnknowns {

  // entry point for creation of feeds from file or network data
  NSError *error = nil;
  NSXMLDocument *xmlDocument = [[[NSXMLDocument alloc] initWithData:data
                                                            options:0
                                                              error:&error] autorelease];
  if (xmlDocument) {
    
    NSXMLElement* root = [xmlDocument rootElement];
    self = [super initWithXMLElement:root
                              parent:nil
                      serviceVersion:serviceVersion
                          surrogates:nil
                shouldIgnoreUnknowns:NO];
    if (self) {
      [self setupFromXMLElement:root];
      
      // we're done parsing; the extension declarations won't be needed again
      [self clearExtensionDeclarationsCache];

#if GDATA_USES_LIBXML
      // retain the document so that pointers to internal nodes remain valid
      [self setProperty:xmlDocument forKey:kGDataXMLDocumentPropertyKey];
#endif
    } 
    return self;
    
  } else {
    // could not parse XML into a document
    [self release]; 
    return nil;
  }
}

- (void)setupFromXMLElement:(NSXMLElement *)root {

  // we'll parse the generator manually rather than declare it to be an
  // extension so that it won't be compared in isEquals: for the feed
  [self setGenerator:[self objectForChildOfElement:root
                                     qualifiedName:@"generator"
                                      namespaceURI:kGDataNamespaceAtom
                                       objectClass:[GDataGenerator class]]];
    
  // call subclasses to set up their feed ivars
  [self initFeedWithXMLElement:root];
  
  // allocate individual entries
  Class entryClass = [self classForEntries];
  
  GDATA_DEBUG_ASSERT([[root localName] isEqual:@"feed"], 
            @"initing a feed from a non-feed element (%@)", [root name]);
  
  // create entries of the proper class from each "entry" element
  id entryObj = [self objectOrArrayForChildrenOfElement:root
                                          qualifiedName:@"entry"
                                           namespaceURI:kGDataNamespaceAtom
                                            objectClass:entryClass];
  if ([entryObj isKindOfClass:[NSArray class]]) {

    // save the array
    [self setEntries:entryObj];

  } else if (entryObj != nil) {

    // save the object into an array
    [self addEntry:entryObj];
  }
}


- (void)dealloc {
  [generator_ release];
  [entries_ release];

  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataFeedBase* newFeed = [super copyWithZone:zone];
  
  [newFeed setGenerator:[self generator]];

  [newFeed setEntriesWithEntries:[self entries]];
  return newFeed;
}


- (BOOL)isEqual:(GDataFeedBase *)other {
  
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataFeedBase class]]) return NO;

  return [super isEqual:other]
    && AreEqualOrBothNil([self entries], [other entries]);
    // excluding generator 
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription { // subclasses may implement this

  NSArray *linkNames = [GDataLink linkNamesFromLinks:[self links]];
  NSString *linksStr = [linkNames componentsJoinedByString:@","];

  struct GDataDescriptionRecord descRecs[] = {
    { @"v",                @"serviceVersion",          kGDataDescValueLabeled },
    { @"entries",          @"entries",                 kGDataDescArrayCount },
    { @"etag",             @"ETag",                    kGDataDescValueLabeled },
    { @"resourceID",       @"resourceID",              kGDataDescValueLabeled },
    { @"title",            @"title.stringValue",       kGDataDescValueLabeled },
    { @"subtitle",         @"subtitle.stringValue",    kGDataDescValueLabeled },
    { @"rights",           @"rights.stringValue",      kGDataDescValueLabeled },
    { @"updated",          @"updatedDate.stringValue", kGDataDescValueLabeled },
    { @"authors",          @"authors",                 kGDataDescArrayCount },
    { @"contributors",     @"contributors",            kGDataDescArrayCount },
    { @"categories",       @"categories",              kGDataDescArrayCount },
    { @"links",            linksStr,                   kGDataDescValueIsKeyPath },
    { @"id",               @"identifier",              kGDataDescValueLabeled },
    { nil, nil, 0 }
  };
  
  // these are present but not very useful most of the time...
  // @"totalResults"
  // @"startIndex"
  // @"itemsPerPage"

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

- (NSXMLElement *)XMLElement {

  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"feed"];
  
  if ([self generator]) {
    [element addChild:[[self generator] XMLElement]]; 
  } 

  [self addToElement:element XMLElementsForArray:[self entries]];

  return element;
}


#pragma mark -

- (void)initFeedWithXMLElement:(NSXMLElement *)element {
 // subclasses override this to set up their feed ivars from the XML 
}

// subclasses may override this, and may return a specific entry class or
// kUseRegisteredEntryClass
- (Class)classForEntries {
  
  return kUseRegisteredEntryClass; 
}

- (BOOL)canPost {
  return ([self postLink] != nil);  
}

#pragma mark Dynamic object generation - Entry registration

//
// feed registration & lookup for dynamic object generation
//

static NSMutableDictionary *gFeedClassCategoryMap = nil;

+ (void)registerFeedClass {

  NSString *kind = [self standardFeedKind];

  GDATA_DEBUG_ASSERT(kind != nil, @"cannot register feed without a kind");

  [self registerClass:self
                inMap:&gFeedClassCategoryMap
forCategoryWithScheme:kGDataCategoryScheme
                 term:kind];
}

+ (void)registerFeedClass:(Class)theClass
     forCategoryWithScheme:(NSString *)scheme
                      term:(NSString *)term {

  // temporary bridge method - will be removed when subclasses all call
  // -registerFeedClass
  [self registerClass:theClass
                inMap:&gFeedClassCategoryMap
forCategoryWithScheme:scheme
                 term:term];
}

+ (Class)feedClassForCategoryWithScheme:(NSString *)scheme
                                   term:(NSString *)term {
  return [self classForCategoryWithScheme:scheme
                                     term:term
                                  fromMap:gFeedClassCategoryMap];
}

#pragma mark Getters and Setters

- (NSString *)identifier {
  GDataAtomID *obj = [self objectForExtensionClass:[GDataAtomID class]];
  return [obj stringValue];
}

- (void)setIdentifier:(NSString *)str {
  GDataAtomID *obj = [GDataAtomID valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataAtomID class]];
}

- (GDataGenerator *)generator {
  return generator_; 
}

- (void)setGenerator:(GDataGenerator *)gen {
  [generator_ autorelease];
  generator_ = [gen copy];
}

- (GDataTextConstruct *)title {
  GDataAtomTitle *obj = [self objectForExtensionClass:[GDataAtomTitle class]];
  return obj;
}

- (void)setTitle:(GDataTextConstruct *)obj {
  [self setObject:obj forExtensionClass:[GDataAtomTitle class]];
}

- (void)setTitleWithString:(NSString *)str {
  GDataAtomTitle *obj = [GDataAtomTitle textConstructWithString:str];
  [self setObject:obj forExtensionClass:[GDataAtomTitle class]];
}

- (GDataTextConstruct *)subtitle {
  GDataAtomSubtitle *obj = [self objectForExtensionClass:[GDataAtomSubtitle class]];
  return obj;
}

- (void)setSubtitle:(GDataTextConstruct *)obj {
  [self setObject:obj forExtensionClass:[GDataAtomSubtitle class]];
}

- (void)setSubtitleWithString:(NSString *)str {
  GDataAtomSubtitle *obj = [GDataAtomSubtitle textConstructWithString:str];
  [self setObject:obj forExtensionClass:[GDataAtomSubtitle class]];
}

- (GDataTextConstruct *)rights {
  GDataTextConstruct *obj;
  
  obj = [self objectForExtensionClass:[GDataAtomRights class]];
  return obj;
}

- (void)setRights:(GDataTextConstruct *)obj {
  [self setObject:obj forExtensionClass:[GDataAtomRights class]];
}

- (void)setRightsWithString:(NSString *)str {
  GDataAtomRights *obj;
  
  obj = [GDataAtomRights textConstructWithString:str];
  [self setObject:obj forExtensionClass:[GDataAtomRights class]];
}

- (NSString *)icon {
  GDataAtomIcon *obj = [self objectForExtensionClass:[GDataAtomIcon class]];
  return [obj stringValue];
}

- (void)setIcon:(NSString *)str {
  GDataAtomIcon *obj = [GDataAtomID valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataAtomIcon class]];
}

- (NSString *)logo {
  GDataAtomLogo *obj = [self objectForExtensionClass:[GDataAtomLogo class]];
  return [obj stringValue];
}

- (void)setLogo:(NSString *)str {
  GDataAtomLogo *obj = [GDataAtomLogo valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataAtomLogo class]];
}

- (NSArray *)links {
  NSArray *array = [self objectsForExtensionClass:[GDataLink class]];
  return array;
}

- (void)setLinks:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataLink class]];
}

- (void)addLink:(GDataLink *)obj {
  [self addObject:obj forExtensionClass:[GDataLink class]];
}

- (void)removeLink:(GDataLink *)obj {
  [self removeObject:obj forExtensionClass:[GDataLink class]];
}

- (NSArray *)authors {
  NSArray *array = [self objectsForExtensionClass:[GDataAtomAuthor class]];
  return array;
}

- (void)setAuthors:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataAtomAuthor class]];
}

- (void)addAuthor:(GDataPerson *)obj {
  [self addObject:obj forExtensionClass:[GDataAtomAuthor class]];
}

- (NSArray *)contributors {
  NSArray *array = [self objectsForExtensionClass:[GDataAtomContributor class]];
  return array;
}

- (void)setContributors:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataAtomContributor class]];
}

- (void)addContributor:(GDataPerson *)obj {
  [self addObject:obj forExtensionClass:[GDataAtomContributor class]];
}

- (NSArray *)categories {
  NSArray *array = [self objectsForExtensionClass:[GDataCategory class]];
  return array;
}

- (void)setCategories:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataCategory class]];
}

- (void)addCategory:(GDataCategory *)obj {
  [self addObject:obj forExtensionClass:[GDataCategory class]];
}

- (void)removeCategory:(GDataCategory *)obj {
  [self removeObject:obj forExtensionClass:[GDataCategory class]];
}

- (GDataDateTime *)updatedDate {
  GDataAtomUpdatedDate *obj;
  
  obj = [self objectForExtensionClass:[GDataAtomUpdatedDate class]];
  return [obj dateTimeValue];
}

- (void)setUpdatedDate:(GDataDateTime *)dateTime {
  GDataAtomUpdatedDate *obj;
  
  obj = [GDataAtomUpdatedDate valueWithDateTime:dateTime];
  [self setObject:obj forExtensionClass:[GDataAtomUpdatedDate class]];
}

- (NSNumber *)totalResults {
  GDataValueElementConstruct *obj;
  Class objClass;
  
  if ([self isServiceVersion1]) {
    objClass = [GDataOpenSearchTotalResults1_0 class];
  } else {
    objClass = [GDataOpenSearchTotalResults1_1 class];
  }
  
  obj = [self objectForExtensionClass:objClass];
  return [obj intNumberValue];
}

- (void)setTotalResults:(NSNumber *)num {
  GDataValueElementConstruct *obj;
  Class objClass;

  if ([self isServiceVersion1]) {
    objClass = [GDataOpenSearchTotalResults1_0 class];
  } else {
    objClass = [GDataOpenSearchTotalResults1_1 class];
  }
  
  obj = [objClass valueWithNumber:num];
  [self setObject:obj forExtensionClass:objClass];
}

- (NSNumber *)startIndex {
  GDataValueElementConstruct *obj;
  Class objClass;
  
  if ([self isServiceVersion1]) {
    objClass = [GDataOpenSearchStartIndex1_0 class];
  } else {
    objClass = [GDataOpenSearchStartIndex1_1 class];
  }
  
  obj = [self objectForExtensionClass:objClass];
  return [obj intNumberValue];
}

- (void)setStartIndex:(NSNumber *)num {
  GDataValueElementConstruct *obj;
  Class objClass;
  
  if ([self isServiceVersion1]) {
    objClass = [GDataOpenSearchStartIndex1_0 class];
  } else {
    objClass = [GDataOpenSearchStartIndex1_1 class];
  }
    
  obj = [objClass valueWithNumber:num];
  [self setObject:obj forExtensionClass:objClass];
}

- (NSNumber *)itemsPerPage {
  GDataValueElementConstruct *obj;
  Class objClass;
  
  if ([self isServiceVersion1]) {
    objClass = [GDataOpenSearchItemsPerPage1_0 class];
  } else {
    objClass = [GDataOpenSearchItemsPerPage1_1 class];
  }
  
  obj = [self objectForExtensionClass:objClass];
  return [obj intNumberValue];
}

- (void)setItemsPerPage:(NSNumber *)num {
  GDataValueElementConstruct *obj;
  Class objClass;

  if ([self isServiceVersion1]) {
    objClass = [GDataOpenSearchItemsPerPage1_0 class];
  } else {
    objClass = [GDataOpenSearchItemsPerPage1_1 class];
  }
  
  obj = [objClass valueWithNumber:num];
  [self setObject:obj forExtensionClass:objClass];
}

- (NSString *)ETag {
  NSString *str = [self attributeValueForExtensionClass:[GDataETagAttribute class]];
  return str;
}

- (void)setETag:(NSString *)str {
  [self setAttributeValue:str forExtensionClass:[GDataETagAttribute class]];
}

- (NSString *)resourceID {
  GDataResourceID *obj = [self objectForExtensionClass:[GDataResourceID class]];
  return [obj stringValue];
}

- (void)setResourceID:(NSString *)str {
  GDataResourceID *obj = [GDataResourceID valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataResourceID class]];
}

- (NSArray *)entries {
  return entries_; 
}

// setEntries: and addEntry: expect the entries to have parents that are
// nil or this feed instance; setEntriesWithEntries: and addEntryWithEntry:
// make copies of the supplied entries

- (void)setEntries:(NSArray *)entries {
  
  [entries_ autorelease];
  entries_ = [entries mutableCopy];
  
  // step through the entries, ensure that none have other parents,
  // make each have this feed as parent
  GDataObject* entry;
  GDATA_FOREACH(entry, entries_) {
    GDataObject *oldParent = [entry parent];
    GDATA_ASSERT(oldParent == self || oldParent == nil,
                 @"Trying to replace existing feed parent; use setEntriesWithEntries: instead");
    [entry setParent:self];
  }
}

- (void)addEntry:(GDataEntryBase *)obj {
    
  if (!entries_) {
    entries_ = [[NSMutableArray alloc] init]; 
  }
  
  // ensure the entry doesn't have another parent
  GDataObject *oldParent = [obj parent];
  GDATA_ASSERT(oldParent == self || oldParent == nil, 
               @"Trying to replace existing feed parent; use addEntryWithEntry: instead");  

  [obj setParent:self];
  [entries_ addObject:obj];
}

- (void)setEntriesWithEntries:(NSArray *)entries {

  // make an array containing copies of the entries with this feed
  // as the parent of each entry copy
  [entries_ autorelease];
  entries_ = nil;

  if (entries != nil) {
    entries_ = [[NSMutableArray alloc] initWithCapacity:[entries count]];

    GDataObject* entry;

    GDATA_FOREACH(entry, entries) {
      GDataEntryBase *entryCopy = [[entry copy] autorelease]; // clears parent in copy
      [entryCopy setParent:self];
      [entries_ addObject:entryCopy];
    }
  }
}

- (void)addEntryWithEntry:(GDataEntryBase *)obj {

  GDataEntryBase *entryCopy = [[obj copy] autorelease]; // clears parent in copy
  [self addEntry:entryCopy];
}

// extensions for Atom publishing control

- (GDataAtomPubControl *)atomPubControl {
  Class class = [GDataAtomPubControl atomPubControlClassForObject:self];
  
  return [self objectForExtensionClass:class];
}

- (void)setAtomPubControl:(GDataAtomPubControl *)obj {
  Class class = [GDataAtomPubControl atomPubControlClassForObject:self];
  
  [self setObject:obj forExtensionClass:class];
}

// extensions for batch support

- (GDataBatchOperation *)batchOperation {
  return [self objectForExtensionClass:[GDataBatchOperation class]];
}

- (void)setBatchOperation:(GDataBatchOperation *)obj {
  [self setObject:obj forExtensionClass:[GDataBatchOperation class]];
}

// convenience routines

- (GDataLink *)feedLink {
  return [GDataLink linkWithRelAttributeValue:kGDataLinkRelFeed
                                    fromLinks:[self links]]; 
}

- (GDataLink *)alternateLink {
  return [GDataLink linkWithRelAttributeValue:@"alternate"
                                    fromLinks:[self links]]; 
}

- (GDataLink *)relatedLink {
  return [GDataLink linkWithRelAttributeValue:@"related"
                                    fromLinks:[self links]]; 
}

- (GDataLink *)postLink {
  return [GDataLink linkWithRelAttributeValue:kGDataLinkRelPost
                                    fromLinks:[self links]]; 
}

- (GDataLink *)batchLink {
  return [GDataLink linkWithRelAttributeValue:kGDataLinkRelBatch
                                    fromLinks:[self links]]; 
}

- (GDataLink *)selfLink {
  return [GDataLink linkWithRelAttributeValue:@"self"
                                    fromLinks:[self links]]; 
}

- (GDataLink *)nextLink {
  return [GDataLink linkWithRelAttributeValue:@"next"
                                    fromLinks:[self links]]; 
}

- (GDataLink *)previousLink {
  return [GDataLink linkWithRelAttributeValue:@"previous"
                                    fromLinks:[self links]]; 
}

- (id)entryForIdentifier:(NSString *)str {

  GDataEntryBase *desiredEntry;
  desiredEntry = [GDataUtilities firstObjectFromArray:[self entries]
                                            withValue:str
                                           forKeyPath:@"identifier"];
  return desiredEntry;
}

- (id)firstEntry {
  NSArray *entries = [self entries];
  if ([entries count] > 0) {
    return [entries objectAtIndex:0];
  }
  return nil;
}

- (NSArray *)entriesWithCategoryKind:(NSString *)term {

  NSArray *kindEntries = [GDataUtilities objectsFromArray:[self entries]
                                                withValue:term
                                               forKeyPath:@"kindCategory.term"];
  return kindEntries;
}

@end


