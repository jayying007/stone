//
//  EvalEnv.swift
//  stone
//
//  Created by janezhuang on 2024/4/2.
//

import Foundation

class Environment {
    var values = [String: Any]()
    var outer: Environment?

    init(env: Environment? = nil) {
        self.outer = env
    }

    func putNew(name: String, value: Any?) {
        if value == nil {
            values.removeValue(forKey: name)
        } else {
            values[name] = value
        }
    }

    func put(name: String, value: Any?) {
        var env = locate(name: name)
        if env == nil {
            env = self
        }
        env?.putNew(name: name, value: value)
    }

    func get(name: String) -> Any? {
        if let value = values[name] {
            return value
        }
        return outer?.get(name: name)
    }

    func locate(name: String) -> Environment? {
        if values[name] != nil {
            return self
        } else if outer == nil {
            return nil
        } else {
            return outer?.locate(name: name)
        }
    }
}
