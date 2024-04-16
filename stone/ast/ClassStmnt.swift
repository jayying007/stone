//
//  ClassStmnt.swift
//  stone
//
//  Created by janezhuang on 2024/4/8.
//

import Foundation

class ClassStmnt: ASTList {
    var name: String {
        return (child(0) as! ASTLeaf).token.value
    }

    var superClass: String? {
        if numChildren() < 3 {
            return nil
        }
        return (child(1) as! ASTLeaf).token.value
    }

    var body: ClassBody {
        return (child(numChildren() - 1) as! ClassBody)
    }

    override func accept(_ visitor: any Visitor) throws {
        try visitor.visit(self)
    }
}

class ClassBody: ASTList {

}
