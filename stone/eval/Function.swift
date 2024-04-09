//
//  Function.swift
//  stone
//
//  Created by janezhuang on 2024/4/7.
//

import Foundation

class Function {
    var parameters: ParameterList
    var body: BlockStmnt
    var env: EvalEnv

    init(parameters: ParameterList, body: BlockStmnt, env: EvalEnv) {
        self.parameters = parameters
        self.body = body
        self.env = env
    }
}
