//
//  NumberLiteral.swift
//  stone
//
//  Created by janezhuang on 2024/3/26.
//

import Foundation

class NumberLiteral: ASTLeaf {

    var number: Int {
        return Int(token.value) ?? 0
    }

    override func accept(_ visitor: Visitor) throws {
        try visitor.visit(self)
    }
}
