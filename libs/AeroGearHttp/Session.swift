/*
* JBoss, Home of Professional Open Source.
* Copyright Red Hat, Inc., and individual contributors
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

import Foundation


protocol Session {
    
    var baseURL: NSURL {get set}
    var session: NSURLSession {get set}
    var requestSerializer: RequestSerializer! {get set}
    var responseSerializer: ResponseSerializer! {get set}
    
    func GET(parameters: [String: AnyObject]?, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) -> Void
    func POST(parameters: [String: AnyObject]?, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) -> Void
    func PUT(parameters: [String: AnyObject]?, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) -> Void
    func DELETE(parameters: [String: AnyObject]?, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) -> Void
    func HEAD(parameters: [String: AnyObject]?, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) -> Void
    func multiPartUpload(parameters: [String: AnyObject], success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) -> Void
}