//
//  DefStmnt.swift
//  stone
//
//  Created by janezhuang on 2024/4/7.
//

import Foundation

class DefStmnt: ASTList {

    var name: String {
        return (child(0) as! ASTLeaf).token.value
    }

    var parameters: ParameterList {
        return child(1) as! ParameterList
    }

    var body: BlockStmnt {
        return child(2) as! BlockStmnt
    }

    override func accept(_ visitor: any Visitor) throws {
        try visitor.visit(self)
    }
}
