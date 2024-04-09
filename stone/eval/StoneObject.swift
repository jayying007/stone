//
//  StoneObject.swift
//  stone
//
//  Created by janezhuang on 2024/4/9.
//

import Foundation

enum StoneError: Error {
    case Default(String)
}

class StoneObject {
    var env: EvalEnv

    init(env: EvalEnv) {
        self.env = env
    }

    func read(member: String) throws -> Any? {
        return try getEnv(member).get(name: member)
    }

    func write(member: String, value: Any?) throws {
        try getEnv(member).putNew(name: member, value: value)
    }

    func getEnv(_ member: String) throws -> EvalEnv {
        let e = env.locate(name: member)
        if e != nil && e! === env {
            return e!
        } else {
            throw StoneError.Default("can't access \(member)")
        }
    }
}
