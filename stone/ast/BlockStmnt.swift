//
//  BlockStmnt.swift
//  stone
//
//  Created by janezhuang on 2024/3/26.
//

import Foundation

class BlockStmnt: ASTList {

    override func accept(_ visitor: Visitor) throws {
        for child in self.children {
            try child.accept(visitor)
        }
    }
}
