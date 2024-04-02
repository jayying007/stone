//
//  WhileStmnt.swift
//  stone
//
//  Created by janezhuang on 2024/3/26.
//

import Foundation

class WhileStmnt: ASTList {

    func condition() -> ASTree {
        return child(0)
    }

    func body() -> ASTree {
        return child(1)
    }

    override func accept(_ visitor: Visitor) throws {
        try visitor.visit(self)
    }
}
