//
//  IfStmnt.swift
//  stone
//
//  Created by janezhuang on 2024/3/26.
//

import Foundation

class IfStmnt: ASTList {

    var condition: ASTree {
        return child(0)
    }

    var thenBlock: ASTree {
        return child(1)
    }

    var elseBlock: ASTree? {
        return numChildren() > 2 ? child(2) : nil
    }

    override func accept(_ visitor: Visitor) throws {
        try visitor.visit(self)
    }
}
