/* Copyright (c) 2008 Google Inc.
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

#import "GDataUtilities.h"
#import <math.h>

@implementation GDataUtilities

+ (NSString *)stringWithControlsFilteredForString:(NSString *)str {
  // Ensure that control characters are not present in the string, since they 
  // would lead to XML that likely will make servers unhappy.  (Are control
  // characters ever legal in XML?)
  //
  // Why not assert on debug builds for the caller when the string has a control
  // character?  The characters may never be present in the data until the
  // program is deployed to users.  This filtering will make it less likely 
  // that bad XML might be generated for users and sent to servers.
  //
  // Since we generate our XML directly from the elements with
  // XMLData, we won't later have a good chance to look for and clean out
  // the control characters.
  
  if (str == nil) return nil;
  
  static NSCharacterSet *filterChars = nil;

  @synchronized([GDataUtilities class]) {

    if (filterChars == nil) {
      // make a character set of control characters (but not whitespace/newline
      // characters), and keep a static immutable copy to use for filtering
      // strings
      NSCharacterSet *ctrlChars = [NSCharacterSet controlCharacterSet];
      NSCharacterSet *newlineWsChars = [NSCharacterSet whitespaceAndNewlineCharacterSet];
      NSCharacterSet *nonNewlineWsChars = [newlineWsChars invertedSet];

      NSMutableCharacterSet *mutableChars = [[ctrlChars mutableCopy] autorelease];
      [mutableChars formIntersectionWithCharacterSet:nonNewlineWsChars];

      [mutableChars addCharactersInRange:NSMakeRange(0x0B, 2)]; // filter vt, ff

      filterChars = [mutableChars copy];
    }
  }
  
  // look for any invalid characters
  NSRange range = [str rangeOfCharacterFromSet:filterChars]; 
  if (range.location != NSNotFound) {
    
    // copy the string to a mutable, and remove null and non-whitespace 
    // control characters
    NSMutableString *mutableStr = [NSMutableString stringWithString:str];  
    while (range.location != NSNotFound) {
      
      GDATA_DEBUG_LOG(@"GDataObject: Removing char 0x%lx from XML element string \"%@\"", 
            [mutableStr characterAtIndex:range.location], str);

      [mutableStr deleteCharactersInRange:range];
      
      range = [mutableStr rangeOfCharacterFromSet:filterChars]; 
    }
    
    return mutableStr;
  }
  
  return str;
}

+ (NSString *)userAgentStringForString:(NSString *)str {

  // make a proper token without whitespace from the given string
  //
  // per http://www.w3.org/Protocols/rfc2616/rfc2616-sec2.html
  // and http://www.mozilla.org/build/user-agent-strings.html

  if (str == nil) return nil;

  NSMutableString *result = [NSMutableString stringWithString:str];

  // replace spaces with underscores
  [result replaceOccurrencesOfString:@" "
                          withString:@"_"
                             options:0
                               range:NSMakeRange(0, [result length])];

  // delete http token separators and remaining whitespace
  static NSCharacterSet *charsToDelete = nil;

  @synchronized([GDataUtilities class]) {

    if (charsToDelete == nil) {

      // make a set of unwanted characters
      NSString *const kSeparators = @"()<>@,;:\\\"/[]?={}";

      NSMutableCharacterSet *mutableChars
        = [[[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy] autorelease];

      [mutableChars addCharactersInString:kSeparators];

      charsToDelete = [mutableChars copy]; // hang on to an immutable copy
    }
  }

  while (true) {
    NSRange separatorRange = [result rangeOfCharacterFromSet:charsToDelete];
    if (separatorRange.location == NSNotFound) break;

    [result deleteCharactersInRange:separatorRange];
  };

  return result;
}

+ (NSNumber *)doubleNumberOrInfForString:(NSString *)str {
  if ([str length] == 0) return nil;

  double val = [str doubleValue];
  NSNumber *number = [NSNumber numberWithDouble:val];

  if (fpclassify(val) == FP_ZERO) {
    if ([str caseInsensitiveCompare:@"INF"] == NSOrderedSame) {
      number = (NSNumber *)kCFNumberPositiveInfinity;
    } else if ([str caseInsensitiveCompare:@"-INF"] == NSOrderedSame) {
      number = (NSNumber *)kCFNumberNegativeInfinity;
    }
  }
  return number;
}

#pragma mark Copy method helpers

+ (NSArray *)arrayWithCopiesOfObjectsInArray:(NSArray *)source {
  if (source == nil) return nil;

  NSArray *result = [[[NSArray alloc] initWithArray:source
                                          copyItems:YES] autorelease];
  return result;
}

+ (NSMutableArray *)mutableArrayWithCopiesOfObjectsInArray:(NSArray *)source {

  if (source == nil) return nil;

  NSMutableArray *result;

  result = [[[NSMutableArray alloc] initWithArray:source
                                        copyItems:YES] autorelease];
  return result;
}

+ (NSDictionary *)dictionaryWithCopiesOfObjectsInDictionary:(NSDictionary *)source {
  if (source == nil) return nil;

  NSDictionary *result = [[[NSDictionary alloc] initWithDictionary:source
                                                         copyItems:YES] autorelease];
  return result;
}

+ (NSMutableDictionary *)mutableDictionaryWithCopiesOfObjectsInDictionary:(NSDictionary *)source {

  if (source == nil) return nil;

  NSMutableDictionary *result;

  result = [[[NSMutableDictionary alloc] initWithDictionary:source
                                                  copyItems:YES] autorelease];
  return result;
}

+ (NSDictionary *)dictionaryWithCopiesOfArraysInDictionary:(NSDictionary *)source {
  // we don't enforce return of an immutable for this
  return [self mutableDictionaryWithCopiesOfArraysInDictionary:source];
}

+ (NSMutableDictionary *)mutableDictionaryWithCopiesOfArraysInDictionary:(NSDictionary *)source {

  // Copy a dictionary that has arrays as its values
  //
  // We want to copy each object in each array.

  if (source == nil) return nil;

  Class arrayClass = [NSArray class];
  
  // Using CFPropertyListCreateDeepCopy would be nice, but it fails on non-plist
  // classes of objects

  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  id key;
  GDATA_FOREACH_KEY(key, source) {

    id origObj = [source objectForKey:key];
    id copyObj;

    if ([origObj isKindOfClass:arrayClass]) {

      copyObj = [self mutableArrayWithCopiesOfObjectsInArray:origObj];
    } else {
      copyObj = [[origObj copy] autorelease];
    }
    [dict setObject:copyObj forKey:key];
  }

  return dict;
}

#pragma mark String encoding 

// URL Encoding

+ (NSString *)stringByURLEncodingString:(NSString *)str {
  NSString *result = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  return result;
}

+ (NSString *)stringByURLEncodingStringParameter:(NSString *)str {
  
  // NSURL's stringByAddingPercentEscapesUsingEncoding: does not escape
  // some characters that should be escaped in URL parameters, like / and ?; 
  // we'll use CFURL to force the encoding of those
  //
  // We'll explicitly leave spaces unescaped now, and replace them with +'s
  //
  // Reference: http://www.ietf.org/rfc/rfc3986.txt
  
  NSString *resultStr = str;
  
  CFStringRef originalString = (CFStringRef) str;
  CFStringRef leaveUnescaped = CFSTR(" ");
  CFStringRef forceEscaped = CFSTR("!*'();:@&=+$,/?%#[]");
  
  CFStringRef escapedStr;
  escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                       originalString,
                                                       leaveUnescaped, 
                                                       forceEscaped,
                                                       kCFStringEncodingUTF8);
  
  if (escapedStr) {
    NSMutableString *mutableStr = [NSMutableString stringWithString:(NSString *)escapedStr];
    CFRelease(escapedStr);
    
    // replace spaces with plusses
    [mutableStr replaceOccurrencesOfString:@" "
                                withString:@"+"
                                   options:0
                                     range:NSMakeRange(0, [mutableStr length])];
    resultStr = mutableStr;
  }
  return resultStr;
}

// percent-encoding UTF-8

+ (NSString *)stringByPercentEncodingUTF8ForString:(NSString *)inputStr {
  
  // encode per http://bitworking.org/projects/atom/rfc5023.html#rfc.section.9.7
  //
  // step through the string as UTF-8, and replace characters outside 20..7E
  // (and the percent symbol itself, 25) with percent-encodings
  //
  // we avoid creating an encoding string unless we encounter some characters
  // that require it
  
  const char* utf8 = [inputStr UTF8String];
  if (utf8 == NULL) {
    return nil;
  }
  
  NSMutableString *encoded = nil;
  
  for (unsigned int idx = 0; utf8[idx] != '\0'; idx++) {
    
    unsigned char currChar = utf8[idx];
    if (currChar < 0x20 || currChar == 0x25 || currChar > 0x7E) {
      
      if (encoded == nil) {
        // start encoding and catch up on the character skipped so far
        encoded = [[[NSMutableString alloc] initWithBytes:utf8
                                                   length:idx 
                                                 encoding:NSUTF8StringEncoding] autorelease];
      }
      
      // append this byte as a % and then uppercase hex
      [encoded appendFormat:@"%%%02X", currChar];
      
    } else {
      // this character does not need encoding
      //
      // encoded is nil here unless we've encountered a previous character 
      // that needed encoding
      [encoded appendFormat:@"%c", currChar];
    }
  }
  
  if (encoded) {
    return encoded;  
  } 
  
  return inputStr;
}

#pragma mark Key-Value Coding Searches in an Array

+ (NSArray *)objectsFromArray:(NSArray *)sourceArray 
                    withValue:(id)desiredValue
                   forKeyPath:(NSString *)keyPath {
  // step through all entries, get the value from 
  // the key path, and see if it's equal to the 
  // desired value
  NSMutableArray *results = [NSMutableArray array];
  id obj;
  
  GDATA_FOREACH(obj, sourceArray) {
    id val = [obj valueForKeyPath:keyPath];
    if (AreEqualOrBothNil(val, desiredValue)) {
      
      // found a match; add it to the results array
      [results addObject:obj];
    }
  }
  return results;
}  

+ (id)firstObjectFromArray:(NSArray *)sourceArray 
                 withValue:(id)desiredValue
                forKeyPath:(NSString *)keyPath {
  
  id obj;
  GDATA_FOREACH(obj, sourceArray) {
    id val = [obj valueForKeyPath:keyPath];
    if (AreEqualOrBothNil(val, desiredValue)) {
      
      // found a match; return it
      return obj;
    }
  }
  return nil;
}

#pragma mark File type helpers

// utility routine to convert a file path to the file's MIME type using
// Mac OS X's UTI database
+ (NSString *)MIMETypeForFileAtPath:(NSString *)path
                    defaultMIMEType:(NSString *)defaultType {
#ifndef GDATA_FOUNDATION_ONLY

  NSString *result = defaultType;

  // convert the path to an FSRef
  FSRef fileFSRef;
  Boolean isDirectory;
  OSStatus err = FSPathMakeRef((UInt8 *) [path fileSystemRepresentation],
                               &fileFSRef, &isDirectory);
  if (err == noErr) {

    // get the UTI (content type) for the FSRef
    CFStringRef fileUTI;
    err = LSCopyItemAttribute(&fileFSRef, kLSRolesAll, kLSItemContentType,
                              (CFTypeRef *)&fileUTI);
    if (err == noErr) {

      // get the MIME type for the UTI
      CFStringRef mimeTypeTag;
      mimeTypeTag = UTTypeCopyPreferredTagWithClass(fileUTI,
                                                    kUTTagClassMIMEType);
      if (mimeTypeTag) {

        // convert the CFStringRef to an autoreleased NSString (ObjC 2.0-safe)
        result = [(id)CFMakeCollectable(mimeTypeTag) autorelease];
      }
      CFRelease(fileUTI);
    }
  }
  return result;

#else // !GDATA_FOUNDATION_ONLY

  return defaultType;

#endif
}

@end

// isEqual: has the fatal flaw that it doesn't deal well with the received
// being nil. We'll use this utility instead.
BOOL AreEqualOrBothNil(id obj1, id obj2) {
  if (obj1 == obj2) {
    return YES;
  }
  if (obj1 && obj2) {
    BOOL areEqual = [obj1 isEqual:obj2];
    
    // the following commented-out lines are useful for finding out what
    // comparisons are failing when XML regeneration fails in unit tests
    
    //if (!areEqual) NSLog(@">>>\n%@\n  !=\n%@", obj1, obj2);  
    
    return areEqual; 
  } else {
    //NSLog(@">>>\n%@\n  !=\n%@", obj1, obj2);  
  }
  return NO;
}

BOOL AreBoolsEqual(BOOL b1, BOOL b2) {
  // avoid comparison problems with boolean types by negating
  // both booleans
  return (!b1 == !b2);
}

