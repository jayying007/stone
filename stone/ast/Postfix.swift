//
//  Postfix.swift
//  stone
//
//  Created by janezhuang on 2024/4/7.
//

import Foundation

class Postfix: ASTList {

}

class Arguments: Postfix {

    override func accept(_ visitor: any Visitor) throws {
        try visitor.visit(self)
    }
}

class Dot: Postfix {
    var name: String {
        return (child(0) as! ASTLeaf).token.value
    }

    override func accept(_ visitor: any Visitor) throws {
        try visitor.visit(self)
    }
}
