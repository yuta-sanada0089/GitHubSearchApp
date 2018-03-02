//
//  GitHub.swift
//  GitHubSearch
//
//  Created by 真田雄太 on 2018/03/02.
//  Copyright © 2018年 yutaSanada. All rights reserved.
//

import Foundation

protocol GitHubEndpoint: APIEndpoint {
    var path: String {get}
}

private let GitHubURL = NSURL(string: "https://api.github.com/")!

extension GitHubEndpoint {
    var Url: URL {
        return Foundation.URL(string: path, relativeToURL: GitHubURL)!
    }
    var Headers: Parameters {
        return[
            "Accept": "application/vnd.github.v3+json",
        ]
    }
}


struct SearchRepositories: GitHubEndpoint {
    var path = "search/repositories"
    var query: Parameters? {
        return[
            "q"    : searchQuery,
            "page" : String(page),
        ]
    }
    typealias ResponseType = SearchResult<Repository>
    
    let searchQuery: String
    let page: Int
    init(searxhQuery: String, page: Int) {
        self.searchQuery = searchQuery
        self.page = page
    }
}

//クロージャー
private let dateFormatter: DateFormatter = {
    let dateFormatter = DataFormatter()
    dateFormatter.calender = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
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
            throw JSONDecoderError.UnexpectedValue(
                key: key, value: value, message: "Invalid date format for '\(dateFormatter.dateFormat)'"
                                                   )
        }
        return date
    }
}
