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

#import "GDataHTTPFetcher.h"

// GData HTTP Logging
//
// All traffic using GDataHTTPFetcher can be easily logged.  Call
//
//   [GDataHTTPFetcher setIsLoggingEnabled:YES];
//
// to begin generating log files.
//
// Log files are put into a folder on the desktop called "GDataHTTPDebugLogs"
// unless another directory is specified with +setLoggingDirectory.
//
// Each run of an application gets a separate set of log files.  An html
// file is generated to simplify browsing the run's http transactions.
// The html file includes javascript links for inline viewing of uploaded
// and downloaded data.
//
// A symlink is created in the logs folder to simplify finding the html file
// for the latest run of the application; the symlink is called 
//
//   AppName_http_log_newest.html
//
// For better viewing of XML logs, use Camino or Firefox rather than Safari.
//
// Projects may define STRIP_GDATA_FETCH_LOGGING to remove logging code.

@interface GDataHTTPFetcher (GDataHTTPFetcherLogging)

// Note: the default logs directory is ~/Desktop/GDataHTTPDebugLogs; it will be
// created as needed.  If a custom directory is set, the directory should
// already exist.
+ (void)setLoggingDirectory:(NSString *)path;
+ (NSString *)loggingDirectory;

// client apps can turn logging on and off
+ (void)setIsLoggingEnabled:(BOOL)flag;
+ (BOOL)isLoggingEnabled;

// client apps can optionally specify process name and date string used in
// log file names
+ (void)setLoggingProcessName:(NSString *)str;
+ (NSString *)loggingProcessName;

+ (void)setLoggingDateStamp:(NSString *)str;
+ (NSString *)loggingDateStamp;

// internal; called by fetcher
- (void)logFetchWithError:(NSError *)error;
- (void)logCapturePostStream;
@end
