//
//  APIRequest.swift
//  GitHubSearch
//
//  Created by 真田雄太 on 2018/03/05.
//  Copyright © 2018年 yutaSanada. All rights reserved.
//

import Foundation

class APIRequest {
    
    static let GITHUB_API: String = "https://api.github.com/search/repositories?q=Hatena&page=1"
    let GITHUB_URL = URL(string: GITHUB_API)
    
    struct Owner {
        let login             : String
        let id                : Int
        let avaterURL         : URL
        let gravatarID        : String
        let url               : URL
        let receivedEventsURL : URL
        let type              : String
        
        init?(json: [String: AnyObject]){
            guard
                let login = json["login"] as? String,
                let id = json["id"] as? Int,
                let avaterURL = (json["avaterURL"] as? String).flatMap(URL.init(string:)),
                let gravatarID = json["garvatarID"] as? String,
                let url = (json["url"] as? String).flatMap(URL.init(string:)),
                let receivedEventsURL = (json["receivedEventsURL"] as? String).flatMap(URL.init(string:)),
                let type = json["type"] as? String
                else {
                    return nil
            }
            
            self.login = login
            self.id = id
            self.avaterURL = avaterURL
            self.gravatarID = gravatarID
            self.url = url
            self.receivedEventsURL = receivedEventsURL
            self.type = type
        }
    }
    
    init() {
        LogUtil.traceFunc()
        request()
    }
    
    private func request() {
        LogUtil.traceFunc()
        
        var urlRequest = URLRequest(url: GITHUB_URL!)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                LogUtil.error(error)
            }
            
            var json1: [String : AnyObject]?
            json1 = try! JSONSerialization.jsonObject(with: data!, options: []) as? [String : AnyObject]
            
            if let json2 = json1 {
                if let items = json2["items"] as? [AnyObject] {
                    for case let item as [String : AnyObject] in items {
                        if let name = item["name"] as? String {
                            LogUtil.debug(name)
                            
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
}

