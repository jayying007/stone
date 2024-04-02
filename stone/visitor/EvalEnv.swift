//
//  EvalEnv.swift
//  stone
//
//  Created by janezhuang on 2024/4/2.
//

import Foundation

class EvalEnv {
    var values = [String: Any]()

    func put(name: String, value: Any?) {
        if value == nil {
            values.removeValue(forKey: name)
        } else {
            values[name] = value
        }
    }

    func get(name: String) -> Any? {
        return values[name]
    }
}
