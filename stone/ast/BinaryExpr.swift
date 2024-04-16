//
//  BinaryExpr.swift
//  stone
//
//  Created by janezhuang on 2024/3/26.
//

import Foundation

class BinaryExpr: ASTList {

    var left: ASTree {
        return child(0)
    }

    var op: String {
        return (child(1) as! ASTLeaf).token.value
    }

    var right: ASTree {
        return child(2)
    }

    override func accept(_ visitor: Visitor) throws {
        try visitor.visit(self)
    }
}
