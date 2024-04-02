//
//  PrimaryExpr.swift
//  stone
//
//  Created by janezhuang on 2024/3/26.
//

import Foundation

class PrimaryExpr: ASTList {
    override func accept(_ visitor: Visitor) throws {
        try visitor.visit(self)
    }
}
