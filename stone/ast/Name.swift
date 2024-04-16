//
//  Name.swift
//  stone
//
//  Created by janezhuang on 2024/3/26.
//

import Foundation

class Name: ASTLeaf {

    var name: String {
        return token.value
    }

    override func accept(_ visitor: Visitor) throws {
        try visitor.visit(self)
    }
}
