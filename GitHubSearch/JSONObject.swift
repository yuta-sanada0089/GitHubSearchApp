//
//  JSONObject.swift
//  GitHubSearch
//
//  Created by 真田雄太 on 2018/03/06.
//  Copyright © 2018年 yutaSanada. All rights reserved.
//


protocol JSONDecodable {
    init(jsonObject: JSONObject) throws
}

enum JSONDecodeError: Error, CustomDebugStringConvertible {
    
    case MissingRequiredKey(String)
    case UnexpectedType(key: String, expected: Any.Type, actual: Any.Type)
    case UnexpectedValue(key: String, value: Any, message: String?)
    
    var debugDescription: String {
        switch self {
        case .MissingRequiredKey(let key):
            return "JSON Decode Error: Required key '\(key)' missing"
        case let .UnexpectedType(key: key, expected: expected, actual: actual):
            return "JSON Decode Error: Unexpected Type '\(actual)' was supplied for '\(key): \(expected)'"
        case let .UnexpectedValue(key: key, value: value, message: message):
            return "JSON Decode Error: \(message ?? "Unexpected value") '\(value)' was supplied for '\(key)'"
        }
    }
}

protocol JSONValueConverter {
    associatedtype FromType
    associatedtype ToType
    
    func convert(key: String, value: FromType) throws -> ToType
}

struct DefaultConverter<T>: JSONValueConverter {
    typealias FromType = T
    typealias ToType = T
    
    func convert(key: String, value: FromType) -> DefaultConverter.ToType {
        return value
    }
}

struct ObjectConverter<T: JSONDecodable>: JSONValueConverter {
    typealias FromType = [String : AnyObject]
    typealias ToType = T
    
    func convert(key: String, value: FromType) throws -> ObjectConverter.ToType {
        return try T(jsonObject: JSONObject(json: value))
    }
}

struct ArrayConverter<T: JSONDecodable>: JSONValueConverter {
    typealias FromType = [[String : AnyObject]]
    typealias ToType = [T]
    
    func convert(key: String, value: FromType) throws -> ArrayConverter.ToType {
        return try value.map(JSONObject.init).map(T.init)
    }
}

protocol JSONPrimitive {}

extension String : JSONPrimitive {}
extension Int    : JSONPrimitive {}
extension Double : JSONPrimitive {}
extension Bool   : JSONPrimitive {}

protocol JSONConvertible {
    associatedtype ConverterType: JSONValueConverter
    static var converter: ConverterType { get }
}

struct JSONObject {
    let json: [String : AnyObject]
    
    init(json: [String : AnyObject]){
        self.json = json
    }
    
    func get<Converter: JSONValueConverter>(_ key: String, converter: Converter) throws -> Converter.ToType {
        guard let value = json[key] else {
            throw JSONDecodeError.MissingRequiredKey(key)
        }
        
        guard let typedValue = value as? Converter.FromType else {
            throw JSONDecodeError.UnexpectedType(key: key, expected: Converter.FromType.self, actual: type(of: value))
        }
        return try converter.convert(key: key, value: typedValue)
    }
    
    func get<Converter: JSONValueConverter>(_ key: String, converter: Converter) throws -> Converter.ToType? {
        guard let value = json[key] else {
            return nil
        }
        
        if value is NSNull {
            return nil
        }
        
        guard let typedValue = value as? Converter.FromType else {
            throw JSONDecodeError.UnexpectedType(key: key, expected: Converter.FromType.self, actual: type(of: value))
        }
        
        return try converter.convert(key: key, value: typedValue)
    }
    
    func get<T: JSONPrimitive>(_ key: String) throws -> T {
        return try get(key, converter: DefaultConverter())
    }
    
    func get<T: JSONPrimitive>(_ key: String) throws -> T? {
        return try get(key, converter: DefaultConverter())
    }
    
    func get<T: JSONConvertible>(_ key: String) throws -> T where T == T.ConverterType.ToType {
        return try get(key, converter: T.converter)
    }
    
    func get<T: JSONConvertible>(_ key: String) throws -> T? where T == T.ConverterType.ToType {
        return try get(key, converter: T.converter)
    }
    
    func get<T: JSONDecodable>(_ key: String) throws -> T {
        return try get(key, converter: ObjectConverter())
    }
    
    func get<T: JSONDecodable>(_ key: String) throws -> T? {
        return try get(key, converter: ObjectConverter())
    }
    
    func get<T: JSONDecodable>(_ key: String) throws -> [T] {
        return try get(key, converter: ArrayConverter())
    }
    
    func get<T: JSONDecodable>(_ key: String) throws -> [T]? {
        return try get(key, converter: ArrayConverter())
    }
}

import Foundation

extension URL: JSONConvertible {
    typealias ConverterType = URLConverter
    static var converter: ConverterType {
        return URLConverter()
    }
}

extension Date: JSONConvertible {
    typealias ConverterType = DateConverter
    static var converter: ConverterType {
        return DateConverter()
    }
}

struct URLConverter: JSONValueConverter {
    typealias FromType = String
    typealias ToType = URL
    
    func convert(key: String, value: FromType) throws -> URLConverter.ToType {
        guard let URL = URL(string: value) else {
            throw JSONDecodeError.UnexpectedValue(key: key, value: value, message: "Invalid URL")
        }
        return URL
    }
}

struct DateConverter: JSONValueConverter {
    typealias FromType = TimeInterval
    typealias ToType = Date
    
    func convert(key: String, value: FromType) -> DateConverter.ToType {
        return Date(timeIntervalSince1970: value)
    }
}
