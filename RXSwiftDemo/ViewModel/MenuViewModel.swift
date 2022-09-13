//
//  MenuViewModel.swift
//  RXSwiftDemo
//
//  Created by yi he on 2022/9/13.
//

import UIKit

class MenuViewModel: NSObject {
    
    let menuSubject = BehaviorRelay<[MenuModel?]>(value: [])
    
    func parseJsonStr() {
        //1 获取json文件路径
        let path = Bundle.main.path(forResource: "system", ofType: "json")
        guard let path = path else { return }
        do {
            let jsonStr = try? String(contentsOfFile: path).replacingOccurrences(of: "\n", with: "")
            guard let json = jsonStr else { return }
            print(json ?? "nil")
            guard let model = json.ivArrayDecode(MenuModel.self) else { return }
            print(model ?? "nil")
            menuSubject.accept(model)
        } catch {
            print(error)
        }
    }
    
}


