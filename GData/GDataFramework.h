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


#ifndef _GDATAFRAMEWORK_H_
#define _GDATAFRAMEWORK_H_

// Returns the version of the framework.  Major and minor should
// match the bundle version in the Info.plist file.
// 
// Pass NULL to ignore any of the parameters.

void GDataFrameworkVersion(long* major, long* minor, long* release);

#endif
