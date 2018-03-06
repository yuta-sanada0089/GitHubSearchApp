//
//  API.swift
//  GitHubSearch
//
//  Created by 真田雄太 on 2018/03/04.
//  Copyright © 2018年 yutaSanada. All rights reserved.
//

import Foundation

enum APIError : Error {
    case EmptyBody
    case UnexpectedResponseType
}

enum HTTPMethod : String {
    case OPTIONS
    case GET
    case HEAD
    case POST
    case PUT
    case DELETE
    case TRACE
    case CONNECT
}

protocol APIEndpoint {
    var Url : URL { get }
    var HttpMethod : HTTPMethod { get }
    var Query : Parameters? { get }
    var Headers : Parameters? { get }
    associatedtype ResponseType : JSONDecodable
}

extension APIEndpoint {
    var HttpMethod : HTTPMethod { return .GET}
    var Query : Parameters? { return nil }
    var Headers : Parameters? { return nil }
}

extension APIEndpoint {
    private var urlRequest: URLRequest {
        var components = URLComponents(url: Url, resolvingAgainstBaseURL: true)
        components?.queryItems = Query?.parameters.map(URLQueryItem.init)
        
        let req = NSMutableURLRequest(url: components?.url ?? Url)
        req.httpMethod = HttpMethod.rawValue
        
        for case let (key, value) in Headers?.parameters ?? [:] {
            req.addValue(value!, forHTTPHeaderField: key)
        }
        
        return req as URLRequest
    }
    
    func request(session: URLSession, callback: @escaping (APIResult<ResponseType>) -> Void) -> URLSessionDataTask {
        LogUtil.traceFunc(className: "APIEndpoint")
        
        let task = session.dataTask(with: urlRequest) {(data,response, error) in
            if let e = error {
                LogUtil.error(e)
                callback(.Failure(e))
            } else if let data = data {
                do {
                    guard let dic = try JSONSerialization.jsonObject(with: data, options: []) as? [String : AnyObject] else {
                        LogUtil.debug("unexpected response type")
                        throw APIError.UnexpectedResponseType
                    }
                    
                    LogUtil.debug(dic.description)
                    
                    let response = try ResponseType(jsonObject: JSONObject(json: dic))
                    LogUtil.debug("response")
                    
                    callback(.Success(response))
                    
                } catch {
                    LogUtil.debug("failure")
                    LogUtil.error(error)
                    
                    callback(.Failure(error))
                }
            } else {
                callback(.Failure(APIError.EmptyBody))
            }
        }
        
        task.resume()
        return task
    }
}

enum APIResult<Response> {
    case Success(Response)
    case Failure(Error)
}

struct Parameters: ExpressibleByDictionaryLiteral {
    typealias Key = String
    typealias Value = String?
    
    private(set) var parameters: [Key: Value] = [:]
    
    init(dictionaryLiteral elements: (String, String?)...) {
        for case let (key, value?) in elements {
            parameters[key] = value
        }
    }
}
