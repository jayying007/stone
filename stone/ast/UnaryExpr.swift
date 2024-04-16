//
//  UnaryExpr.swift
//  stone
//
//  Created by janezhuang on 2024/3/26.
//

import Foundation

class UnaryExpr: ASTList {

    var op: String {
        return (child(0) as! ASTLeaf).token.value
    }

    var value: ASTree {
        return child(1)
    }

    override func accept(_ visitor: Visitor) throws {
        try visitor.visit(self)
    }
}
