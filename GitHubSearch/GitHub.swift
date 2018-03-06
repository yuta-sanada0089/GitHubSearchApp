//
//  GitHub.swift
//  GitHubSearch
//
//  Created by 真田雄太 on 2018/03/02.
//  Copyright © 2018年 yutaSanada. All rights reserved.
//

import Foundation

protocol GitHubEndpoint: APIEndpoint {
    var Path: String { get }
}

private let GitHubURL = URL(string: "https://api.github.com/")!

extension GitHubEndpoint {
    var Url: URL {
        return Foundation.URL(string: Path, relativeTo: GitHubURL)!
    }
    var Headers: Parameters {
        return[ "Accept": "application/vnd.github.v3+json" ]
    }
}


struct SearchRepositories: GitHubEndpoint {
    var Path = "search/repositories"
    
    typealias ResponseType = SearchResult<Repository>
    
    var Query: Parameters? {
        return[
            "q"    : searchQuery,
            "page" : String(page)
        ]
    }
    
    
    let searchQuery: String
    let page: Int
    init(searchQuery: String, page: Int) {
        self.searchQuery = searchQuery
        self.page = page
    }
}

//クロージャー
private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    return dateFormatter
}()


struct FormattedDateConverter: JSONValueConverter {
    typealias FromType = String
    typealias ToType = Date
    
    private let dateFormatter: DateFormatter
    
    internal init(dateFormatter: DateFormatter){
        self.dateFormatter = dateFormatter
    }
    
    func convert(key: String, value: FromType) throws -> DateConverter.ToType {
        guard let date = dateFormatter.date(from: value) else {
            throw JSONDecodeError.UnexpectedValue(
                key: key, value: value, message: "Invalid date format for '\(dateFormatter.dateFormat)'"
            )
        }
        return date
    }
}

struct SearchResult<ItemType: JSONDecodable>: JSONDecodable {
    let total_count : Int
    let incomplete_results : Bool
    let items : [ItemType]
    
    init(jsonObject: JSONObject) throws {
        
        LogUtil.traceFunc(className: "SearchResult")
        
        self.total_count = try jsonObject.get("total_count")
        LogUtil.debug("\(total_count)")
        
        self.incomplete_results = try jsonObject.get("incomplete_results")
        LogUtil.debug("\(incomplete_results)")
        
        self.items = try jsonObject.get("items")
        LogUtil.debug("C")
        
        LogUtil.traceFunc(className: "SearchResult", message: "done")
    }
}

struct Repository: JSONDecodable {
    let id                : Int
    let name              : String
    let full_name         : String
    let owner             : Owner
    let is_private        : Bool
    let html_url          : URL
    let description       : String?
    let fork              : Bool
    let url               : URL
    let created_at        : Date
    let updated_at        : Date
    let pushed_at         : Date?
    let homepage          : String?
    let size              : Int
    let stargazers_count  : Int
    let watchers_count    : Int
    let language          : String?
    let forks_count       : Int
    let open_issues_count : Int
    let default_branch    : String
    let score             : Double
    
    init(jsonObject: JSONObject) throws {
        LogUtil.traceFunc(className: "Repository")
        
        self.id                = try jsonObject.get("id")
        self.name              = try jsonObject.get("name")
        self.full_name         = try jsonObject.get("full_name")
        self.owner             = try jsonObject.get("owner")
        self.is_private        = try jsonObject.get("private")
        self.html_url          = try jsonObject.get("html_url")
        self.description       = try jsonObject.get("description")
        self.fork              = try jsonObject.get("fork")
        self.url               = try jsonObject.get("url")
        self.created_at        = try jsonObject.get("created_at", converter: FormattedDateConverter(dateFormatter: dateFormatter))as Date
        self.updated_at        = try jsonObject.get("update_at", converter: FormattedDateConverter(dateFormatter: dateFormatter))as Date
        self.pushed_at         = try jsonObject.get("pushed_at", converter: FormattedDateConverter(dateFormatter: dateFormatter))as Date
        self.homepage          = try jsonObject.get("homepage")
        self.size              = try jsonObject.get("size")
        self.stargazers_count  = try jsonObject.get("stargazers_count")
        self.watchers_count    = try jsonObject.get("watchers_count")
        self.language          = try jsonObject.get("language")
        self.forks_count       = try jsonObject.get("forks_count")
        self.open_issues_count = try jsonObject.get("open_issues_count")
        self.default_branch    = try jsonObject.get("default_branch")
        self.score             = try jsonObject.get("score")
        
        LogUtil.traceFunc(className: "Repository", message: "done")
    }
}

struct Owner: JSONDecodable {
    let login             : String
    let id                : Int
    let avaterURL         : URL
    let gravaterID        : String
    let url               : URL
    let receivedEventsURL : URL
    let type              : String
    
    init(jsonObject: JSONObject) throws {
        LogUtil.traceFunc(className:"Owner")
        
        self.login             = try jsonObject.get("login")
        self.id                = try jsonObject.get("id")
        self.avaterURL         = try jsonObject.get("avater_url")
        self.gravaterID        = try jsonObject.get("gravater_id")
        self.url               = try jsonObject.get("url")
        self.receivedEventsURL = try jsonObject.get("received_events_url")
        self.type              = try jsonObject.get("type")
        
        LogUtil.traceFunc(className: "Owner", message: "done")
    }
}
