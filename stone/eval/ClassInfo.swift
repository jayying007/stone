//
//  ClassInfo.swift
//  stone
//
//  Created by janezhuang on 2024/4/9.
//

import Foundation

class ClassInfo {
    var definition: ClassStmnt
    var superClass: ClassInfo?
    var env: Environment

    init(definition: ClassStmnt, env: Environment) {
        self.definition = definition
        self.env = env
        if definition.superClass != nil {
            superClass = env.get(name: definition.superClass!) as? ClassInfo
        }
    }

    func body() -> ClassBody {
        return definition.body
    }
}
