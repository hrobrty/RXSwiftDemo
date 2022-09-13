//
//  StringExtention.swift
//  RXSwiftDemo
//
//  Created by yi he on 2022/9/13.
//

import Foundation

extension String {
    /// json 解析
    /// - Parameter type: 遵守 Codable 协议的Model.self
    /// - Returns: 解析完成的model
    func decode<T: Codable>(_ type: T.Type) -> T? {
        let jsonData = data(using: .utf8)!
        var model: T? = nil
        do {
            model = try JSONDecoder().decode(type, from: jsonData)
        } catch {
           // logWarning(error)
        }
        return model
    }

    /// json 解析 字典 解出data对应model
    /// - Parameter type: 遵守 Codable 协议的Model.self
    func ivDecode<T: Codable>(_ type: T.Type) -> T? {
        return decode(IVModel<T>.self)?.data
    }

    /// json 解析 数组 解出data对应model
    /// - Parameter type: 遵守 Codable 协议的Model.self
    func ivArrayDecode<T: Codable>(_ type: T.Type) -> [T?]? {
        return decode(IVArrayModel<T>.self)?.data.list ?? []
    }
    
}

// MARK: - IVModel

struct IVModel<T>: Codable where T: Codable {
    @codableDef.EmptyString var msg: String
    @codableDef.Zero var code: Int
    var data: T?
}

// MARK: - IVArrayModel

struct IVArrayModel<T: Codable>: Codable {
    @codableDef.Zero var code: Int
    @codableDef.EmptyString var msg: String
  //  var data: [T?]?
    var data: IVListArrayModel<T>
}

struct IVListArrayModel<T: Codable>: Codable {
    var list: [T?]
}
