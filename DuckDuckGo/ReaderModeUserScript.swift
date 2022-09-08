//
//  ReaderModeUserScript.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Core
import WebKit
import BrowserServicesKit

// swiftlint:disable:next identifier_name
let ReaderModeNamespace = "window.__firefox__.reader"

enum ReaderModeMessageType: String {
    case stateChange = "ReaderModeStateChange"
    case pageEvent = "ReaderPageEvent"
    case contentParsed = "ReaderContentParsed"
}

public class ReaderModeUserScript: NSObject, UserScript {

    public lazy var source: String = {
        return Self.loadJS("ReaderMode", from: Bundle.main)
    }()
    
    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    
    public var forMainFrameOnly: Bool = false
    
    public var messageNames: [String] = ["readerModeMessageHandler"]
    
    var findInPage: FindInPage?
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let msg = message.body as? [String: Any],
              let type = msg["Type"] as? String,
              let messageType = ReaderModeMessageType(rawValue: type)
        else { return }

//        switch messageType {
//        case .pageEvent:
//            if let readerPageEvent = ReaderPageEvent(rawValue: msg["Value"] as? String ?? "Invalid") {
//                handleReaderPageEvent(readerPageEvent)
//            }
//        case .stateChange:
//            if let readerModeState = ReaderModeState(rawValue: msg["Value"] as? String ?? "Invalid") {
//                handleReaderModeStateChange(readerModeState)
//            }
//        case .contentParsed:
//            if let readabilityResult = ReadabilityResult(object: msg["Value"] as AnyObject?) {
//                handleReaderContentParsed(readabilityResult)
//            }
//        }
    }

}
