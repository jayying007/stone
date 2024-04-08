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

    init(parameters: ParameterList, body: BlockStmnt) {
        self.parameters = parameters
        self.body = body
    }
}
