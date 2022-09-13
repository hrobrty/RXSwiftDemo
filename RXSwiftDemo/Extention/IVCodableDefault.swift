//
//  IVCodableDefault.swift
//  Yoosee
//
//  Created by zhaoyong on 2021/6/10.
//  Copyright © 2021 Gwell. All rights reserved.
//
//  实现一个对 JSON 进行 Codable 解析时配置默认值的功能
//  例如：
/*
 struct Article: Decodable {
 var title: String
 var body: String
 var isRead: Bool = true
 }
 */

// 当遇到如下 JSON 时， isRead 均无法配置默认值，且会解析失败, 只能将 isRead 声明成 Bool?，但是可选值会带来其他复杂化度
/*
 {
 "title": "测试",
 "body": "内容",
 "isRead": null
 }
 Or:
 {
 "title": "测试",
 "body": "内容",
 }
 */

// 用本工具类配置默认值，则均可以解析成功

import Foundation

// MARK: - CodableDefaultSource

/// 默认值来源 泛型协议
public protocol CodableDefaultSource {
    associatedtype Value: Codable
    static var defaultValue: Value { get }
}

// MARK: - CodableDefault

/// 默认值Decoble 命名空间
public enum CodableDefault {}

/// 默认值 Decodable 命名空间 CodableDefault 简写
public typealias codableDef = CodableDefault

// 创建一个泛型的属性包装器
public extension CodableDefault {
    @propertyWrapper
    struct Wrapper<Source: CodableDefaultSource> {
        typealias Value = Source.Value
        
        public var wrappedValue = Source.defaultValue
        public init() { }
    }
}

// MARK: - CodableDefault.Wrapper + Decodable

// 使泛型属性包装器遵守 Decodable 协议
extension CodableDefault.Wrapper: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Value.self)
    }
}

// 重载 decode 方法，实现解析失败时，设置默认值
extension KeyedDecodingContainer {
    func decode<T>(_ type: CodableDefault.Wrapper<T>.Type, forKey key: Key) throws -> CodableDefault.Wrapper<T> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

public extension CodableDefault {
    typealias Source = CodableDefaultSource
    // List 代表 数组（遵守数组字面量协议的）
    typealias List = Codable & ExpressibleByArrayLiteral
    // Map 代表 字典 （遵守字典字面量协议的）
    typealias Map = Codable & ExpressibleByDictionaryLiteral
    
    enum Sources {
        /// 默认值为 true
        public enum True: Source {
            public static var defaultValue: Bool { true }
        }
        
        /// 默认值为 false
        public enum False: Source {
            public static var defaultValue: Bool { false }
        }
        
        /// 默认值为 0
        public enum Zero: Source {
            public static var defaultValue: Int { 0 }
        }
        
        /// 默认值为 -1
        public enum One: Source {
            public static var defaultValue: Int { 1 }
        }
        
        /// 默认值为 -1
        public enum NegOne: Source {
            public static var defaultValue: Int { -1 }
        }
        
        /// 默认值为 空字符串
        public enum EmptyString: Source {
            public static var defaultValue: String { "" }
        }
        
        /// 默认值为 空数组
        public enum EmptyList<T: List>: Source {
            public static var defaultValue: T { [] }
        }
        
        /// 默认值为 空字典
        public enum EmptyMap<T: Map>: Source {
            public static var defaultValue: T { [:] }
        }
        
        /// 默认值为 IVBool.off
        public enum OFF: Source {
            public static var defaultValue: IVBool { .off }
        }
        
        /// 默认值为 IVBool.on
        public enum ON: Source {
            public static var defaultValue: IVBool { .on }
        }
    }
}


// 取 别名 简化语法
public extension CodableDefault {
    /// 默认值为 IVBool.on
    typealias ON = Wrapper<Sources.ON>
    /// 默认值为 IVBool.off
    typealias OFF = Wrapper<Sources.OFF>
    /// 默认值为 1
    typealias One = Wrapper<Sources.One>
    /// 默认值为 0
    typealias Zero = Wrapper<Sources.Zero>
    /// 默认值为 -1
    typealias NegOne = Wrapper<Sources.NegOne>
    /// 默认值为 true
    typealias True = Wrapper<Sources.True>
    /// 默认值为 false
    typealias False = Wrapper<Sources.False>
    /// 默认值为 空字符串
    typealias EmptyString = Wrapper<Sources.EmptyString>
    /// 默认值为 空字典
    typealias EmptyMap<T: Map> = Wrapper<Sources.EmptyMap<T>>
    /// 默认值为 空数组
    typealias EmptyList<T: List> = Wrapper<Sources.EmptyList<T>>
}

// MARK: - CodableDefault.Wrapper + Equatable

// 使包装器遵守常见协议
extension CodableDefault.Wrapper: Equatable where Value: Equatable {}

// MARK: - CodableDefault.Wrapper + Hashable

extension CodableDefault.Wrapper: Hashable where Value: Hashable {}

// MARK: - CodableDefault.Wrapper + Encodable

// 使包装器遵守 Encodable 协议， 此时就遵守了 Codable 协议了
extension CodableDefault.Wrapper: Encodable where Value: Encodable {}
// 这个用来实现 Encodable 协议，因为 public 不能用来声明上面扩展，因为其实对协议的扩展
public extension CodableDefault.Wrapper {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

/// 开关状态值
@objc public enum IVBool: Int, Codable {
    case off = 0
    case on = 1
    public var isOn: Bool {
        set { self = newValue ? .on : .off }
        get { self == .on }
    }
}

/// 不支持 加开关状态
@objc public enum IVStatus: Int, Codable {
    case unsupported = 0    /// 不支持
    case disable     = 1    /// 关
    case enable      = 2    /// 开
    public var isOn: Bool { /// 开启或关闭状态
        set { self = newValue ? .enable : .disable }
        get { self == .enable}
    }
}

public extension IVBool {
    static prefix func ! (value: IVBool) -> IVBool {
        if value == .off {
            return .on
        } else {
            return .off
        }
    }
}


// MARK: - Article_Test

// 举例
private struct Article_Test: Codable {
    var title: String
    var body: String
    @codableDef.True var isRead: Bool
    @codableDef.Zero var readCount: Int
    @codableDef.EmptyList var readers: [String]
    @codableDef.EmptyMap var flags: [String: Bool]
}
