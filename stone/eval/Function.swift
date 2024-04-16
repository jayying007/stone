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
    var env: Environment

    init(parameters: ParameterList, body: BlockStmnt, env: Environment) {
        self.parameters = parameters
        self.body = body
        self.env = env
    }
}
