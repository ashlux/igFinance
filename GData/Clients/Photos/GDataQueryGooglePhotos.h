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

//
//  GDataQueryGooglePhotos.h
//

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAQUERYGOOGLEPHOTOS_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN const int kGDataGooglePhotosImageSizeDownloadable _INITIALIZE_AS(-1);

#import "GDataQuery.h"

@interface GDataQueryGooglePhotos : GDataQuery 

+ (GDataQueryGooglePhotos *)photoQueryWithFeedURL:(NSURL *)feedURL;

+ (GDataQueryGooglePhotos *)photoQueryForUserID:(NSString *)userID
                                        albumID:(NSString *)albumIDorNil
                                      albumName:(NSString *)albumNameOrNil
                                        photoID:(NSString *)photoIDorNil;

- (void)setKind:(NSString *)str;
- (NSString *)kind;

- (void)setAccess:(NSString *)str;
- (NSString *)access;

- (void)setThumbsize:(int)val;
- (int)thumbsize;

// imageSize is the imgmax parameter; see documentation for legal values,
// and explanation of which sizes may be cropped or embedded into web pages
//
// Pass kGDataGooglePhotosImageSizeDownloadable to specify that links should be
// for the native download size for each photo ("imgmax=d")
- (void)setImageSize:(int)val;
- (int)imageSize;

- (void)setTag:(NSString *)tag;
- (NSString *)tag;
  
@end

